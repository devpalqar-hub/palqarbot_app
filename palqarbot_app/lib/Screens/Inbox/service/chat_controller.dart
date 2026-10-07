import 'dart:async';

import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Constants/api_constants.dart';
import 'package:palqarbot_app/Core/Network/api_client.dart';
import 'package:palqarbot_app/Screens/Inbox/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/service/inbox_controller.dart';

class ChatController extends GetxController {
  final String profileId;
  final Conversation conversation;

  ChatController({required this.profileId, required this.conversation});

  final ApiClient _apiClient = ApiClient();

  final messages = <ChatMessage>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final isToggling = false.obs;
  late final RxBool aiEnabled = conversation.aiEnabled.obs;

  Timer? _timer;
  StreamSubscription? _sub;
  bool _busy = false;
  int _failures = 0;

  @override
  void onInit() {
    super.onInit();
    _firstLoad();
  }

  Future<void> _firstLoad() async {
    await _fetch();
    isLoading.value = false;
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _fetch());

    if (Get.isRegistered<InboxController>()) {
      _sub = Get.find<InboxController>().changes.stream.listen(_onChange);
    }
  }

  void _onChange(({String? id, Map<String, dynamic> data}) change) {
    final mine = change.id == null || change.id == conversation.id;
    if (!mine) return;

    final ai = change.data['aiEnabled'];
    if (ai is bool && change.id == conversation.id) aiEnabled.value = ai;

    _fetch();
  }

  Future<void> _fetch() async {
    if (_busy) return;
    _busy = true;

    try {
      final response = await _apiClient.get<dynamic>(
        ApiConstants.inboxMessages(profileId, conversation.id),
        queryParameters: {'limit': '200', 'skip': '0'},
      );

      if (!response.success) {
        _failures++;
        if (_failures >= 3) _timer?.cancel();
        return;
      }

      _failures = 0;
      final list = extractList(response.data)
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      list.sort((a, b) {
        final x = a.createdAt, y = b.createdAt;
        if (x == null || y == null) return 0;
        return x.compareTo(y);
      });

      // keep messages still waiting for the server so they don't blink away
      final pending = messages.where((m) => m.id.startsWith('local-')).toList();
      final stillPending = pending.where((p) => !list.any((m) => m.text == p.text && m.sender != Sender.customer));
      messages.value = [...list, ...stillPending];
    } finally {
      _busy = false;
    }
  }

  Future<bool> send(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || isSending.value) return false;

    isSending.value = true;
    final temp = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      text: clean,
      createdAt: DateTime.now(),
      sender: Sender.agent,
    );
    messages.add(temp);

    final response = await _apiClient.post<dynamic>(
      ApiConstants.inboxSend(profileId, conversation.id),
      body: {'text': clean},
    );

    isSending.value = false;

    if (!response.success) {
      messages.remove(temp);
      return false;
    }

    _updateInbox(lastMessage: clean);
    _fetch();
    return true;
  }

  Future<void> toggleAi(bool value) async {
    if (isToggling.value) return;

    final old = aiEnabled.value;
    aiEnabled.value = value;
    isToggling.value = true;

    final response = await _apiClient.patch<dynamic>(
      ApiConstants.inboxAi(profileId, conversation.id),
      body: {'aiEnabled': value},
    );

    isToggling.value = false;

    if (!response.success) {
      aiEnabled.value = old;
      return;
    }

    _updateInbox(aiEnabled: value);
  }

  void _updateInbox({bool? aiEnabled, String? lastMessage}) {
    if (Get.isRegistered<InboxController>()) {
      Get.find<InboxController>().updateConversation(
        conversation.id,
        aiEnabled: aiEnabled,
        lastMessage: lastMessage,
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _sub?.cancel();
    _apiClient.dispose();
    super.onClose();
  }
}
