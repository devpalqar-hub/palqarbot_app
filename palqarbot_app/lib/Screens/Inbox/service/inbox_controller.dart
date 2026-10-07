import 'dart:async';

import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Inbox/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/service/inbox_socket.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

enum InboxFilter { all, whatsapp, instagram, unread }

class InboxController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final conversations = <Conversation>[].obs;
  final isLoading = true.obs;
  final loadFailed = false.obs;
  final errorText = ''.obs;
  final filter = InboxFilter.all.obs;
  final search = ''.obs;

  String profileId = '';
  Timer? _timer;
  Timer? _debounce;
  InboxSocket? _socket;
  bool _busy = false;
  int _failures = 0;

  // chat screens listen to this to know when something changed on the server
  final changes = StreamController<({String? id, Map<String, dynamic> data})>.broadcast();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    loadFailed.value = false;
    _failures = 0;
    await _fetch();
    isLoading.value = false;
    _startPolling();
  }

  Future<void> refreshList() async {
    _failures = 0;
    await _fetch();
    _startPolling();
  }

  // polling is only a backup now, the socket does the live updates
  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());

    if (_socket == null && profileId.isNotEmpty) {
      _socket = InboxSocket(profileId: profileId, onEvent: _onSocketEvent);
      _socket!.connect();
    }
  }

  void _onSocketEvent(String event, dynamic data) {
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final inner = map['conversation'] is Map ? Map<String, dynamic>.from(map['conversation']) : null;

    final id = (map['conversationId'] ?? inner?['id'] ?? (event == 'conversation.updated' ? map['id'] : null))
        ?.toString();

    changes.add((id: id, data: inner ?? map));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
  }

  Future<void> _fetch() async {
    if (_busy) return;
    _busy = true;

    try {
      if (profileId.isEmpty) {
        final settings = Get.isRegistered<ProfileSettingsController>()
            ? Get.find<ProfileSettingsController>()
            : Get.put(ProfileSettingsController());
        if (settings.profileId.isEmpty) await settings.getUserProfile();
        profileId = settings.profileId;
      }

      if (profileId.isEmpty) profileId = await _findProfileId();

      if (profileId.isEmpty) {
        _failed('No profile found for this account');
        return;
      }

      final response = await _apiClient.get<dynamic>(
        ApiConstants.inboxConversations(profileId),
        queryParameters: {'limit': '100', 'skip': '0'},
      );

      if (!response.success) {
        _failed('${response.statusCode}: ${response.message ?? 'Request failed'}');
        return;
      }

      _failures = 0;
      errorText.value = '';
      loadFailed.value = false;
      conversations.value = extractList(response.data)
          .whereType<Map>()
          .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.id.isNotEmpty)
          .toList();
    } finally {
      _busy = false;
    }
  }

  // used when /auth/me has no profiles, try the other profile lists
  Future<String> _findProfileId() async {
    for (final url in [ApiConstants.myProfiles, ApiConstants.addprofiles]) {
      final response = await _apiClient.get<dynamic>(url);
      if (!response.success) continue;

      for (final item in extractList(response.data)) {
        if (item is! Map) continue;
        final inner = item['profile'] is Map ? item['profile'] as Map : null;
        final id = (inner?['id'] ?? item['profileId'] ?? item['id'])?.toString() ?? '';
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  void _failed(String reason) {
    errorText.value = reason;
    _failures++;
    loadFailed.value = conversations.isEmpty;
    if (_failures >= 3) _timer?.cancel();
  }

  void updateConversation(String id, {bool? aiEnabled, String? lastMessage}) {
    final i = conversations.indexWhere((c) => c.id == id);
    if (i == -1) return;
    conversations[i] = conversations[i].copyWith(
      aiEnabled: aiEnabled,
      lastMessage: lastMessage,
      lastAt: lastMessage == null ? null : DateTime.now(),
    );
  }

  bool matches(Conversation c, InboxFilter f) {
    switch (f) {
      case InboxFilter.all:
        return true;
      case InboxFilter.whatsapp:
        return c.channel == Channel.whatsapp;
      case InboxFilter.instagram:
        return c.channel == Channel.instagram;
      case InboxFilter.unread:
        return c.unread > 0;
    }
  }

  int count(InboxFilter f) => conversations.where((c) => matches(c, f)).length;

  List<Conversation> get visible {
    final q = search.value.toLowerCase();
    return conversations.where((c) {
      if (!matches(c, filter.value)) return false;
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _debounce?.cancel();
    _socket?.dispose();
    changes.close();
    _apiClient.dispose();
    super.onClose();
  }
}
