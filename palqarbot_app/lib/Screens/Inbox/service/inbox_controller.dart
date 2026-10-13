
import 'dart:async';

import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Inbox/model/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/service/inbox_socket.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

enum InboxFilter {
  all,
  whatsapp,
  instagram,
  unread,
  active,
  humanTakeover,
  converted,
  closed,
  blocked,
}

class InboxController extends GetxController {
  static const int pageSize = 20;

  final ApiClient _apiClient = ApiClient();

  final conversations = <Conversation>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final loadFailed = false.obs;
  final errorText = ''.obs;

  final filter = InboxFilter.all.obs;
  final search = ''.obs;

  String profileId = '';

  bool hasMore = true;
  int _nextSkip = 0;
  bool _busy = false;
  bool _disposed = false;
  int _failures = 0;

  Timer? _timer;
  Timer? _debounce;
  InboxSocket? _socket;

  final changes =
      StreamController<({String? id, Map<String, dynamic> data})>.broadcast();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // ---------------------------------------------------------------------------
  // INITIAL LOAD
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    if (_disposed) return;

    isLoading.value = true;
    loadFailed.value = false;
    errorText.value = '';
    _failures = 0;

    _resetPagination(clearConversations: true);

    try {
      await _fetchPage(skip: 0);
    } finally {
      if (!_disposed) {
        isLoading.value = false;
        _startPolling();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH
  // ---------------------------------------------------------------------------

  Future<void> refreshList() async {
    if (_disposed || _busy) return;

    _failures = 0;
    loadFailed.value = false;
    errorText.value = '';

    _resetPagination(clearConversations: true);

    await _fetchPage(skip: 0);
    _startPolling();
  }

  // ---------------------------------------------------------------------------
  // LOAD NEXT PAGE
  // ---------------------------------------------------------------------------

  Future<void> loadMore() async {
    if (_disposed ||
        _busy ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMore ||
        profileId.isEmpty) {
      return;
    }

    isLoadingMore.value = true;

    try {
      await _fetchPage(
        skip: _nextSkip,
        append: true,
      );
    } finally {
      if (!_disposed) {
        isLoadingMore.value = false;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // FILTER
  // ---------------------------------------------------------------------------

  Future<void> changeFilter(InboxFilter newFilter) async {
    if (_disposed || filter.value == newFilter) return;

    filter.value = newFilter;
    isLoading.value = true;
    loadFailed.value = false;
    errorText.value = '';

    _resetPagination(clearConversations: true);

    try {
      await _fetchPage(skip: 0);
    } finally {
      if (!_disposed) {
        isLoading.value = false;
      }
    }
  }

  void _resetPagination({required bool clearConversations}) {
    _nextSkip = 0;
    hasMore = true;
    isLoadingMore.value = false;

    if (clearConversations) {
      conversations.clear();
    }
  }

  // ---------------------------------------------------------------------------
  // API PAGINATION
  // ---------------------------------------------------------------------------

  Future<void> _fetchPage({
    required int skip,
    bool append = false,
    bool preserveExisting = false,
  }) async {
    if (_disposed || _busy) return;

    _busy = true;

    try {
      await _ensureProfileId();

      if (profileId.isEmpty) {
        _failed('No profile found for this account');
        return;
      }

      final queryParameters = <String, String>{
        'limit': '$pageSize',
        'skip': '$skip',
      };

      final status = _statusFromFilter(filter.value);

      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiClient.get<dynamic>(
        ApiConstants.inboxConversations(profileId),
        queryParameters: queryParameters,
      );

      if (_disposed) return;

      if (!response.success) {
        _failed(
          '${response.statusCode}: ${response.message ?? 'Request failed'}',
        );
        return;
      }

      final fetched = extractList(response.data)
          .whereType<Map>()
          .map(
            (item) => Conversation.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((conversation) => conversation.id.isNotEmpty)
          .toList();

      _failures = 0;
      loadFailed.value = false;
      errorText.value = '';

      if (preserveExisting) {
        // Refresh the newest page without deleting conversations
        // already loaded from older pages.
        final merged = <String, Conversation>{};

        for (final conversation in fetched) {
          merged[conversation.id] = conversation;
        }

        for (final conversation in conversations) {
          merged.putIfAbsent(
            conversation.id,
            () => conversation,
          );
        }

        conversations.assignAll(merged.values);
        return;
      }

      if (append) {
        final existingIds = conversations
            .map((conversation) => conversation.id)
            .toSet();

        final newConversations = fetched
            .where(
              (conversation) => existingIds.add(conversation.id),
            )
            .toList();

        conversations.addAll(newConversations);
      } else {
        conversations.assignAll(fetched);
      }

      _nextSkip = skip + fetched.length;
      hasMore = fetched.length >= pageSize;
    } catch (error, stackTrace) {
      if (!_disposed) {
        _failed('Unable to load conversations. Please try again.');
      }

      // Keep the error available during development.
      // Remove this logging if your project uses another logger.
      print('Inbox pagination error: $error');
      print(stackTrace);
    } finally {
      _busy = false;
    }
  }

  Future<void> _ensureProfileId() async {
    if (profileId.isNotEmpty) return;

    final settings = Get.isRegistered<ProfileSettingsController>()
        ? Get.find<ProfileSettingsController>()
        : Get.put(ProfileSettingsController());

    if (settings.profileId.isEmpty) {
      await settings.getUserProfile();
    }

    profileId = settings.profileId;

    if (profileId.isEmpty) {
      profileId = await _findProfileId();
    }
  }

  // ---------------------------------------------------------------------------
  // POLLING AND SOCKET UPDATES
  // ---------------------------------------------------------------------------

  void _startPolling() {
    if (_disposed) return;

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshLatestPage(),
    );

    if (_socket == null && profileId.isNotEmpty) {
      _socket = InboxSocket(
        profileId: profileId,
        onEvent: _onSocketEvent,
      );

      _socket!.connect();
    }
  }

  Future<void> _refreshLatestPage() async {
    if (_disposed || _busy || conversations.isEmpty) return;

    await _fetchPage(
      skip: 0,
      preserveExisting: true,
    );
  }

  void _onSocketEvent(String event, dynamic data) {
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    final inner = map['conversation'] is Map
        ? Map<String, dynamic>.from(map['conversation'])
        : null;

    final id = (
      map['conversationId'] ??
      inner?['id'] ??
      (event == 'conversation.updated' ? map['id'] : null)
    )?.toString();

    if (!_disposed) {
      changes.add((id: id, data: inner ?? map));
    }

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      _refreshLatestPage,
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER HELPERS
  // ---------------------------------------------------------------------------

  String? _statusFromFilter(InboxFilter filter) {
    switch (filter) {
      case InboxFilter.all:
      case InboxFilter.whatsapp:
      case InboxFilter.instagram:
      case InboxFilter.unread:
        return null;

      case InboxFilter.active:
        return 'ACTIVE';

      case InboxFilter.humanTakeover:
        return 'HUMAN_TAKEOVER';

      case InboxFilter.converted:
        return 'CONVERTED';

      case InboxFilter.closed:
        return 'CLOSED';

      case InboxFilter.blocked:
        return 'BLOCKED';
    }
  }

  bool matches(Conversation conversation, InboxFilter filter) {
    switch (filter) {
      case InboxFilter.all:
        return true;

      case InboxFilter.whatsapp:
        return conversation.channel == Channel.whatsapp;

      case InboxFilter.instagram:
        return conversation.channel == Channel.instagram;

      case InboxFilter.unread:
        return conversation.unread > 0;

      case InboxFilter.active:
      case InboxFilter.humanTakeover:
      case InboxFilter.converted:
      case InboxFilter.closed:
      case InboxFilter.blocked:
        return true;
    }
  }

  int count(InboxFilter filter) {
    return conversations
        .where((conversation) => matches(conversation, filter))
        .length;
  }

  List<Conversation> get visible {
    final query = search.value.trim().toLowerCase();

    return conversations.where((conversation) {
      if (!matches(conversation, filter.value)) return false;

      if (query.isEmpty) return true;

      return conversation.name.toLowerCase().contains(query) ||
          conversation.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  String filterLabel(InboxFilter filter) {
    switch (filter) {
      case InboxFilter.all:
        return 'All';
      case InboxFilter.whatsapp:
        return 'WhatsApp';
      case InboxFilter.instagram:
        return 'Instagram';
      case InboxFilter.unread:
        return 'Unread';
      case InboxFilter.active:
        return 'Active';
      case InboxFilter.humanTakeover:
        return 'Human Takeover';
      case InboxFilter.converted:
        return 'Converted';
      case InboxFilter.closed:
        return 'Closed';
      case InboxFilter.blocked:
        return 'Blocked';
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE LOOKUP
  // ---------------------------------------------------------------------------

  Future<String> _findProfileId() async {
    for (final url in [
      ApiConstants.myProfiles,
      ApiConstants.addprofiles,
    ]) {
      final response = await _apiClient.get<dynamic>(url);

      if (!response.success) continue;

      for (final item in extractList(response.data)) {
        if (item is! Map) continue;

        final inner = item['profile'] is Map
            ? item['profile'] as Map
            : null;

        final id = (
          inner?['id'] ??
          item['profileId'] ??
          item['id']
        )?.toString() ?? '';

        if (id.isNotEmpty) return id;
      }
    }

    return '';
  }

  void _failed(String reason) {
    errorText.value = reason;
    _failures++;

    loadFailed.value = conversations.isEmpty;

    if (_failures >= 3) {
      _timer?.cancel();
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE CONVERSATION LOCALLY
  // ---------------------------------------------------------------------------

  void updateConversation(
    String id, {
    bool? aiEnabled,
    String? lastMessage,
  }) {
    final index = conversations.indexWhere(
      (conversation) => conversation.id == id,
    );

    if (index == -1) return;

    conversations[index] = conversations[index].copyWith(
      aiEnabled: aiEnabled,
      lastMessage: lastMessage,
      lastAt: lastMessage == null ? null : DateTime.now(),
    );
  }

  @override
  void onClose() {
    _disposed = true;

    _timer?.cancel();
    _debounce?.cancel();
    _socket?.dispose();

    changes.close();
    _apiClient.dispose();

    super.onClose();
  }
}
