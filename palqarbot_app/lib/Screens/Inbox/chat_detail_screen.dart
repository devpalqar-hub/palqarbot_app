
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Inbox/model/inbox_models.dart';
import 'package:palqarbot_app/Screens/Inbox/inboxscreen.dart';
import 'package:palqarbot_app/Screens/Inbox/service/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;
  final String profileId;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.profileId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final ChatController c;
  late final String _tag;

  @override
  void initState() {
    super.initState();

    _tag = widget.conversation.id;

    c = Get.put(
      ChatController(
        profileId: widget.profileId,
        conversation: widget.conversation,
      ),
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

      if (max - _scroll.offset < 160.h || _scroll.offset == 0) {
        _scroll.animateTo(
          max,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final value = _text.text;

    if (value.trim().isEmpty) return;

    _text.clear();

    final ok = await c.send(value);

    if (!ok && mounted && _text.text.isEmpty) {
      _text.text = value;
    }
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

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
            ChatAvatar(
              name: conv.name,
              channel: conv.channel,
              size: 40.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title,
                  ),
                  Row(
                    children: [
                      Icon(
                        isWhatsapp
                            ? Icons.chat_rounded
                            : Icons.camera_alt_rounded,
                        size: 13.sp,
                        color: isWhatsapp
                            ? AppColors.whatsapp
                            : AppColors.instagram,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isWhatsapp ? 'WhatsApp' : 'Instagram',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: Row(
              children: [
                if (conv.leadStatus != null && conv.tags.isNotEmpty) ...[
                  TagPill(tag: conv.tags.first),
                  SizedBox(width: 8.w),
                ],
              ],
            ),
          ),

          // Bot / manual reply control
          Obx(
            () => Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: c.aiEnabled.value
                          ? AppColors.infoLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      c.aiEnabled.value
                          ? Icons.smart_toy_rounded
                          : Icons.person_rounded,
                      size: 20.sp,
                      color: c.aiEnabled.value
                          ? AppColors.info
                          : AppColors.warning,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Reply (Bot)',
                          style: AppTextStyles.titleMedium,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          c.aiEnabled.value
                              ? 'Bot is replying automatically'
                              : 'Manual mode - you reply yourself',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: c.aiEnabled.value,
                      activeThumbColor: AppColors.textWhite,
                      activeTrackColor: AppColors.success,
                      onChanged:
                          c.isToggling.value ? null : c.toggleAi,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Messages
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final list = c.messages;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }

              return ListView.builder(
                controller: _scroll,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final message = list[i];
                  final previous = i > 0 ? list[i - 1] : null;

                  final newDay = message.createdAt != null &&
                      (previous?.createdAt == null ||
                          previous!.createdAt!.toLocal().day !=
                              message.createdAt!.toLocal().day ||
                          message.createdAt!
                                  .difference(previous.createdAt!)
                                  .inHours >=
                              24);

                  return Column(
                    children: [
                      if (newDay)
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _dayLabel(message.createdAt!.toLocal()),
                            style: AppTextStyles.captionMedium,
                          ),
                        ),
                      _MessageBubble(
                        message: message,
                        customerName: conv.name,
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Message input
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      onSubmitted: (_) => _send(),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      width: 46.w,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColors.textWhite,
                        size: 22.sp,
                      ),
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

// ================================================================
// MESSAGE BUBBLE
// ================================================================

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String customerName;

  const _MessageBubble({
    required this.message,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final fromCustomer = message.sender == Sender.customer;
    final width = MediaQuery.sizeOf(context).width;

    final footer = switch (message.sender) {
      Sender.customer => message.time,
      Sender.bot => '${message.time} · Bot',
      Sender.agent => '${message.time} · You',
    };

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: width * 0.68),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
      decoration: BoxDecoration(
        color: fromCustomer ? AppColors.surface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attachments
          if (message.attachments.isNotEmpty)
            ...message.attachments.map(
              (attachment) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _AttachmentView(attachment: attachment),
              ),
            ),

          // Message text
          if (message.text.trim().isNotEmpty &&
              message.attachments.isEmpty)
            Text(
              message.text,
              style: AppTextStyles.bodyMedium,
            ),

          SizedBox(height: 4.h),

          // Message footer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                footer,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11.sp,
                ),
              ),
              if (!fromCustomer) ...[
                SizedBox(width: 4.w),
                message.failed
                    ? Icon(
                        Icons.error_outline_rounded,
                        size: 14.sp,
                        color: AppColors.error,
                      )
                    : Icon(
                        Icons.done_all_rounded,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
              ],
            ],
          ),
        ],
      ),
    );

    final letter = customerName.isNotEmpty
        ? customerName[0].toUpperCase()
        : '?';

    final side = fromCustomer
        ? CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              letter,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : CircleAvatar(
            radius: 16.r,
            backgroundColor: message.sender == Sender.bot
                ? AppColors.infoLight
                : AppColors.primaryLight,
            child: Icon(
              message.sender == Sender.bot
                  ? Icons.smart_toy_rounded
                  : Icons.person_rounded,
              size: 18.sp,
              color: message.sender == Sender.bot
                  ? AppColors.info
                  : AppColors.primary,
            ),
          );

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: fromCustomer
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: fromCustomer
            ? [side, SizedBox(width: 8.w), bubble]
            : [bubble, SizedBox(width: 8.w), side],
      ),
    );
  }
}

// ================================================================
// ATTACHMENT VIEW
// ================================================================

class _AttachmentView extends StatelessWidget {
  final ChatAttachment attachment;

  const _AttachmentView({
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return _ImageAttachment(attachment: attachment);
    }

    if (attachment.isAudio) {
      return _AudioAttachment(attachment: attachment);
    }

    return const SizedBox.shrink();
  }
}

// ================================================================
// IMAGE ATTACHMENT
// ================================================================

class _ImageAttachment extends StatelessWidget {
  final ChatAttachment attachment;

  const _ImageAttachment({
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        attachment.url,
        width: 240.w,
        height: 240.h,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: 240.w,
            height: 180.h,
            alignment: Alignment.center,
            color: AppColors.surfaceSecondary,
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 240.w,
            height: 120.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 32.sp,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Unable to load image',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// AUDIO ATTACHMENT
// ================================================================

class _AudioAttachment extends StatefulWidget {
  final ChatAttachment attachment;

  const _AudioAttachment({
    required this.attachment,
  });

  @override
  State<_AudioAttachment> createState() => _AudioAttachmentState();
}

class _AudioAttachmentState extends State<_AudioAttachment> {
  late final AudioPlayer _player;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = widget.attachment.url.trim();

      debugPrint('======================================');
      debugPrint('AUDIO URL');
      debugPrint(url);
      debugPrint('======================================');

      if (url.isEmpty) {
        throw Exception('Audio URL is empty');
      }

      final duration = await _player.setUrl(url);

      debugPrint('AUDIO LOADED SUCCESSFULLY');
      debugPrint('AUDIO DURATION: $duration');

      if (mounted) {
        setState(() {
          _loading = false;
          _error = null;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('AUDIO LOAD ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('======================================');

      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_loading) return;

    if (_error != null) {
      await _loadAudio();
      return;
    }

    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e, stackTrace) {
      debugPrint('AUDIO PLAY ERROR: $e');
      debugPrint(stackTrace.toString());

      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: _togglePlay,
                borderRadius: BorderRadius.circular(30.r),
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _loading
                      ? Padding(
                          padding: EdgeInsets.all(12.r),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textWhite,
                          ),
                        )
                      : StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;

                            if (_error != null) {
                              return Icon(
                                Icons.refresh_rounded,
                                size: 22.sp,
                                color: AppColors.textWhite,
                              );
                            }

                            final processingState =
                                state?.processingState;

                            if (processingState ==
                                    ProcessingState.loading ||
                                processingState ==
                                    ProcessingState.buffering) {
                              return Padding(
                                padding: EdgeInsets.all(12.r),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textWhite,
                                ),
                              );
                            }

                            return Icon(
                              state?.playing == true
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 24.sp,
                              color: AppColors.textWhite,
                            );
                          },
                        ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position =
                        positionSnapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, durationSnapshot) {
                        final duration =
                            durationSnapshot.data ?? Duration.zero;

                        final max = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;

                        final value = position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, max)
                            .toDouble();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.graphic_eq_rounded,
                                  size: 18.sp,
                                ),
                                const Spacer(),
                                Text(
                                  _formatDuration(position),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),

                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2.h,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 5.r,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: max,
                                value: value,
                                onChanged: duration.inMilliseconds > 0
                                    ? (newValue) {
                                        _player.seek(
                                          Duration(
                                            milliseconds:
                                                newValue.toInt(),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            SizedBox(height: 6.h),
            Text(
              'Audio failed to load',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(1, '0');
    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}
