import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/widgets/app_searchfield.dart';
import 'package:palqarbot_app/Screens/Inbox/chat_detail_screen.dart';
import 'package:palqarbot_app/Screens/Inbox/model/inbox_models.dart';

import 'package:palqarbot_app/Screens/Inbox/service/inbox_controller.dart';
import 'package:palqarbot_app/Screens/Inbox/widget/connect_channelcard.dart';
import 'package:palqarbot_app/Screens/Inbox/widget/inbox_channel_connection.dart';
import 'package:palqarbot_app/Screens/Settings/service/profile_setting_controller.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final InboxController c = Get.put(InboxController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasConnectedChannel {
    final settingsController = Get.find<ProfileSettingsController>();
    final profile = settingsController.selectedProfile;

    final isWhatsAppConnected =
        (profile?.whatsappConfig?.enabled ?? false) ||
        (profile?.openWaConfig?.enabled ?? false);

    final isInstagramConnected = profile?.instagramConfig?.enabled ?? false;

    return isWhatsAppConnected || isInstagramConnected;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inbox', style: AppTextStyles.heading2),
                      Text(
                        'All your customer conversations',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                _PopupFilterButton(
                  selectedFilter: c.filter,
                  onSelected: c.changeFilter,
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          SizedBox(
            height: 30.h,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _chip('All', InboxFilter.all, null),
                  _chip('WhatsApp', InboxFilter.whatsapp, AppColors.whatsapp),
                  _chip(
                    'Instagram',
                    InboxFilter.instagram,
                    AppColors.instagram,
                  ),
                  _chip('Unread', InboxFilter.unread, null),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AppSearchField(
              hint: 'Search name, phone or message...',
              onChanged: (value) {
                c.search.value = value;
              },
            ),
          ),

          SizedBox(height: 12.h),

          Expanded(child: Obx(_buildBody)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (c.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.loadFailed.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load conversations',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),

              if (c.errorText.value.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 0),
                  child: Text(
                    c.errorText.value,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),

              SizedBox(height: 8.h),

              TextButton(onPressed: c.load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    final list = c.visible;

    if (!_hasConnectedChannel) {
      return const _InboxDisconnectedEmptyState();
    }

    return RefreshIndicator(
      onRefresh: c.refreshList,
      child: list.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 80.h),
                Center(
                  child: Text(
                    'No conversations found',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              itemCount: list.length + (c.isLoadingMore.value ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, i) {
                // Pagination loading indicator
                if (i >= list.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final conversation = list[i];

                return _ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          conversation: conversation,
                          profileId: c.profileId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // ============================================================
  // CHANNEL CHIP
  // ============================================================

  Widget _chip(String label, InboxFilter filter, Color? dot) {
    final selected = c.filter.value == filter;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => c.changeFilter(filter),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Icon(
                  filter == InboxFilter.whatsapp
                      ? Icons.chat_rounded
                      : Icons.camera_alt_rounded,
                  size: 15.sp,
                  color: dot,
                ),
                SizedBox(width: 5.w),
              ],
              Text(
                '$label (${c.count(filter)})',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12.sp,
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

// ================================================================
// STATUS FILTER DROPDOWN
// ================================================================

class _PopupFilterButton extends StatelessWidget {
  final Rx<InboxFilter> selectedFilter;
  final ValueChanged<InboxFilter> onSelected;

  const _PopupFilterButton({
    required this.selectedFilter,
    required this.onSelected,
  });

  String _filterName(InboxFilter filter) {
    switch (filter) {
      case InboxFilter.all:
        return 'All';
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
      case InboxFilter.whatsapp:
        return 'WhatsApp';
      case InboxFilter.instagram:
        return 'Instagram';
      case InboxFilter.unread:
        return 'Unread';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<InboxFilter>(
      onSelected: onSelected,
      offset: Offset(0, 46.h),
      position: PopupMenuPosition.under,
      elevation: 8,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (context) {
        final filters = [
          InboxFilter.all,
          InboxFilter.active,
          InboxFilter.humanTakeover,
          InboxFilter.converted,
          InboxFilter.closed,
          InboxFilter.blocked,
        ];

        final currentFilter = selectedFilter.value;

        return filters.map((filter) {
          final selected = currentFilter == filter;

          return PopupMenuItem<InboxFilter>(
            value: filter,
            height: 46.h,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _filterName(filter),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_rounded,
                    size: 19.sp,
                    color: AppColors.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ================================================================
// ROUND ICON
// ================================================================

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
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

// ================================================================
// DISCONNECTED EMPTY STATE
// ================================================================

class _InboxDisconnectedEmptyState extends StatelessWidget {
  const _InboxDisconnectedEmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160.h,
            width: double.infinity,
            child: Image.asset('assets/empty.png', fit: BoxFit.contain),
          ),

          Text(
            'Connect a channel to get started',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Link your WhatsApp Business or Instagram account '
            'to see and reply to customer messages here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.captionMedium.copyWith(
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          ConnectChannelCard(
            title: 'WhatsApp Business',
            subtitle: 'Connect your business number',
            icon: Icons.chat_rounded,
            color: AppColors.whatsapp,
            onTap: InboxChannelConnection.connectWhatsApp,
          ),

          SizedBox(height: 16.h),

          ConnectChannelCard(
            title: 'Instagram',
            subtitle: 'Connect your professional account',
            icon: Icons.camera_alt_rounded,
            color: AppColors.instagram,
            onTap: InboxChannelConnection.connectInstagram,
          ),

          SizedBox(height: 14.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'Your conversations will appear here once connected.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CONVERSATION TILE
// ================================================================

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
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatAvatar(name: c.name, channel: c.channel, size: 52.r),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(fontSize: 14.sp),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      c.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
                    ),

                    if (c.tags.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [for (final tag in c.tags) TagPill(tag: tag)],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    c.time,
                    style: AppTextStyles.caption.copyWith(fontSize: 10.sp),
                  ),

                  SizedBox(height: 8.h),

                  if (hasUnread)
                    Container(
                      width: 22.w,
                      height: 22.h,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${c.unread}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (c.aiEnabled)
                    Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.info,
                      size: 26.sp,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CHAT AVATAR
// ================================================================

class ChatAvatar extends StatelessWidget {
  final String name;
  final Channel channel;
  final double size;

  const ChatAvatar({
    super.key,
    required this.name,
    required this.channel,
    this.size = 52,
  });

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

    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = colors[letter.codeUnitAt(0) % colors.length];

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
              letter,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),

          Positioned(
            right: -2.w,
            bottom: -2.h,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: isWhatsapp ? AppColors.whatsapp : AppColors.instagram,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5.w),
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

// ================================================================
// TAG PILL
// ================================================================

class TagPill extends StatelessWidget {
  final ChatTag tag;

  const TagPill({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: tag.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        tag.label,
        style: AppTextStyles.caption.copyWith(
          fontSize: 10.sp,
          color: tag.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
