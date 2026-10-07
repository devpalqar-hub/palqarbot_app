import 'package:flutter/material.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Inbox/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/inboxscreen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages = List.of(widget.conversation.messages);
  bool _autoReply = true;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(ChatMessage(text, 'Now', Sender.agent)));
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    final isWhatsapp = c.channel == Channel.whatsapp;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ChatAvatar(name: c.name, channel: c.channel, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: AppTextStyles.title),
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
                if (c.tags.isNotEmpty) TagPill(tag: c.tags.first),
                const SizedBox(width: 8),
                const _ActionPill(icon: Icons.person_add_alt_rounded, label: 'Assign'),
                const SizedBox(width: 8),
                const _ActionPill(icon: Icons.sell_outlined, label: 'Add Tag'),
              ],
            ),
          ),
          Container(
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
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.info),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto Reply (Bot)', style: AppTextStyles.titleMedium),
                      Text('Automatically reply to new messages', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Switch(
                  value: _autoReply,
                  activeThumbColor: AppColors.textWhite,
                  activeTrackColor: AppColors.success,
                  onChanged: (v) => setState(() => _autoReply = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Today', style: AppTextStyles.captionMedium),
                    ),
                  );
                }
                return _MessageBubble(message: _messages[i - 1], customerName: c.name);
              },
            ),
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
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
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
                const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
              ],
            ],
          ),
        ],
      ),
    );

    final side = fromCustomer
        ? CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              customerName[0].toUpperCase(),
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
