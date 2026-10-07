import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Inbox/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/inboxscreen.dart';
import 'package:palqarbot_app/Screens/Inbox/service/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;
  final String profileId;

  const ChatDetailScreen({super.key, required this.conversation, required this.profileId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  late final ChatController c;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = widget.conversation.id;
    c = Get.put(
      ChatController(profileId: widget.profileId, conversation: widget.conversation),
      tag: _tag,
    );
    ever(c.messages, (_) => _scrollToEnd());
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    Get.delete<ChatController>(tag: _tag);
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (max - _scroll.offset < 160 || _scroll.offset == 0) {
        _scroll.animateTo(max, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final value = _text.text;
    if (value.trim().isEmpty) return;
    _text.clear();
    final ok = await c.send(value);
    if (!ok && mounted && _text.text.isEmpty) _text.text = value;
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final isWhatsapp = conv.channel == Channel.whatsapp;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ChatAvatar(name: conv.name, channel: conv.channel, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.title),
                  Row(
                    children: [
                      Icon(
                        isWhatsapp ? Icons.chat_rounded : Icons.camera_alt_rounded,
                        size: 13,
                        color: isWhatsapp ? AppColors.whatsapp : AppColors.instagram,
                      ),
                      const SizedBox(width: 4),
                      Text(isWhatsapp ? 'WhatsApp' : 'Instagram', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                if (conv.leadStatus != null && conv.tags.isNotEmpty) ...[
                  TagPill(tag: conv.tags.first),
                  const SizedBox(width: 8),
                ],
                const _ActionPill(icon: Icons.person_add_alt_rounded, label: 'Assign'),
                const SizedBox(width: 8),
                const _ActionPill(icon: Icons.sell_outlined, label: 'Add Tag'),
              ],
            ),
          ),
          Obx(
            () => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.aiEnabled.value ? AppColors.infoLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      c.aiEnabled.value ? Icons.smart_toy_rounded : Icons.person_rounded,
                      color: c.aiEnabled.value ? AppColors.info : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto Reply (Bot)', style: AppTextStyles.titleMedium),
                        Text(
                          c.aiEnabled.value
                              ? 'Bot is replying automatically'
                              : 'Manual mode - you reply yourself',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: c.aiEnabled.value,
                    activeThumbColor: AppColors.textWhite,
                    activeTrackColor: AppColors.success,
                    onChanged: c.isToggling.value ? null : c.toggleAi,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = c.messages;
              if (list.isEmpty) {
                return Center(child: Text('No messages yet', style: AppTextStyles.bodySmall));
              }

              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final m = list[i];
                  final prev = i > 0 ? list[i - 1] : null;
                  final newDay = m.createdAt != null &&
                      (prev?.createdAt == null ||
                          prev!.createdAt!.toLocal().day != m.createdAt!.toLocal().day ||
                          m.createdAt!.difference(prev.createdAt!).inHours >= 24);

                  return Column(
                    children: [
                      if (newDay)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_dayLabel(m.createdAt!.toLocal()), style: AppTextStyles.captionMedium),
                        ),
                      _MessageBubble(message: m, customerName: conv.name),
                    ],
                  );
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      onSubmitted: (_) => _send(),
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded, color: AppColors.textWhite, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String customerName;

  const _MessageBubble({required this.message, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final fromCustomer = message.sender == Sender.customer;
    final width = MediaQuery.of(context).size.width;

    final footer = switch (message.sender) {
      Sender.customer => message.time,
      Sender.bot => '${message.time} · Bot',
      Sender.agent => '${message.time} · You',
    };

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: width * 0.68),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: fromCustomer ? AppColors.surface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.text, style: AppTextStyles.body),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(footer, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              if (!fromCustomer) ...[
                const SizedBox(width: 4),
                message.failed
                    ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error)
                    : const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
              ],
            ],
          ),
        ],
      ),
    );

    final letter = customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';

    final side = fromCustomer
        ? CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              letter,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          )
        : CircleAvatar(
            radius: 16,
            backgroundColor: message.sender == Sender.bot ? AppColors.infoLight : AppColors.primaryLight,
            child: Icon(
              message.sender == Sender.bot ? Icons.smart_toy_rounded : Icons.person_rounded,
              size: 18,
              color: message.sender == Sender.bot ? AppColors.info : AppColors.primary,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: fromCustomer ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: fromCustomer
            ? [side, const SizedBox(width: 8), bubble]
            : [bubble, const SizedBox(width: 8), side],
      ),
    );
  }
}
