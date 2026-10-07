import 'package:flutter/material.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_searchfield.dart';
import 'package:palqarbot_app/Screens/Inbox/chat_detail_screen.dart';
import 'package:palqarbot_app/Screens/Inbox/inbox_models.dart';

enum InboxFilter { all, whatsapp, instagram, unread }

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  InboxFilter _filter = InboxFilter.all;
  String _search = '';

  int _count(InboxFilter f) => dummyConversations.where((c) => _matchesFilter(c, f)).length;

  bool _matchesFilter(Conversation c, InboxFilter f) {
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

  List<Conversation> get _visible {
    final q = _search.toLowerCase();
    return dummyConversations.where((c) {
      if (!_matchesFilter(c, _filter)) return false;
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inbox', style: AppTextStyles.heading2),
                    Text('All your customer conversations', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _RoundIcon(icon: Icons.search_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _RoundIcon(icon: Icons.tune_rounded, onTap: () {}),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _chip('All', InboxFilter.all, null),
              _chip('WhatsApp', InboxFilter.whatsapp, AppColors.whatsapp),
              _chip('Instagram', InboxFilter.instagram, AppColors.instagram),
              _chip('Unread', InboxFilter.unread, null),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSearchField(
            hint: 'Search name, phone or message...',
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text('No conversations found', style: AppTextStyles.bodySmall))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ConversationTile(
                    conversation: list[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: list[i])),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, InboxFilter f, Color? dot) {
    final selected = _filter == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            children: [
              if (dot != null) ...[
                Icon(
                  f == InboxFilter.whatsapp ? Icons.chat_rounded : Icons.camera_alt_rounded,
                  size: 15,
                  color: dot,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                '$label (${_count(f)})',
                style: AppTextStyles.label.copyWith(
                  color: selected ? AppColors.textWhite : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final hasUnread = c.unread > 0;

    return Material(
      color: hasUnread ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatAvatar(name: c.name, channel: c.channel, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: AppTextStyles.title),
                    const SizedBox(height: 2),
                    Text(
                      c.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [for (final t in c.tags) TagPill(tag: t)],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(c.time, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  if (hasUnread)
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${c.unread}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (c.botActive)
                    const Icon(Icons.smart_toy_rounded, color: AppColors.info, size: 26),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  final String name;
  final Channel channel;
  final double size;

  const ChatAvatar({super.key, required this.name, required this.channel, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final isWhatsapp = channel == Channel.whatsapp;
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.instagram,
    ];
    final color = colors[name.codeUnitAt(0) % colors.length];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: isWhatsapp ? AppColors.whatsapp : AppColors.instagram,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: Icon(
                isWhatsapp ? Icons.chat_rounded : Icons.camera_alt_rounded,
                size: size * 0.2,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  final ChatTag tag;

  const TagPill({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: tag.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag.label,
        style: AppTextStyles.caption.copyWith(color: tag.color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
