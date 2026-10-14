import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/chats/models/message_model.dart';
import 'package:villas_qatar/modules/chats/service/chat_controller.dart';


class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.find<ChatController>();

  final List<String> quickReplies = [
    "Can we schedule a visit?".tr,
    "Is the price negotiable?".tr,
    "What is the payment plan?".tr,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
          onPressed: Get.back,
        ),
        titleSpacing: 0,
        title: GetBuilder<ChatController>(
          builder: (_) {
            final seller =
                controller.conversation?.listing.createdBy;

            return Row(
              children: [
             CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        seller?.name ?? "Seller".tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        controller.isTyping
                            ? "Typing...".tr
                            : "Online".tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: GetBuilder<ChatController>(
        builder: (_) {

          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [

              Expanded(
                child: controller.messages.isEmpty
                    ?  Center(
                        child: Text(
                          "No Messages Yet".tr,
                        ),
                      )
                    : ListView.separated(
                        controller:
                            controller.scrollController,
                        padding: EdgeInsets.all(16.w),

                        itemCount:
                            controller.messages.length +
                                (controller.isLoadingMore
                                    ? 1
                                    : 0),

                        separatorBuilder: (_, __) =>
                            SizedBox(height: 12.h),

                        itemBuilder: (_, index) {

                          if (controller.isLoadingMore &&
                              index == 0) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          final message =
                              controller.messages[
                                  controller.isLoadingMore
                                      ? index - 1
                                      : index];

                          return TextBubble(
                            message: message,
                            isMe:
                                message.sender.id ==
                                    controller.myUserId,
                          );
                        },
                      ),
              ),

              SizedBox(
                height: 40.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: quickReplies.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: 8.w),
                  itemBuilder: (_, index) {

                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {

                        controller.messageController.text =
                            quickReplies[index];

                      },
                      child: Text(
                        quickReplies[index],
                        style: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Divider(
                height: 1.h,
              ),

              InputBar(
                controller: controller,
              ),
            ],
          );
        },
      ),
    );
  }
}


class TextBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const TextBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
        CircleAvatar(
              radius: 15.r,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.person,
                size: 17,
                color: AppColors.primary,
              ),
            ),
        SizedBox(width: 8.w),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * .72,
                  ),
                  padding:  EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft:
                          Radius.circular(isMe ? 18 : 5),
                      bottomRight:
                          Radius.circular(isMe ? 5 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _messageWidget(context),
                ),

                const SizedBox(height: 4),

                Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: 4.h,
                  ),
                  child: Text(
                    DateFormat("hh:mm a".tr)
                        .format(message.createdAt),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageWidget(BuildContext context) {
    switch (message.type.toUpperCase()) {
      case "IMAGE":
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: GestureDetector(
            onTap: () {
              if (message.mediaUrl == null) return;

              showDialog(
                context: context,
                builder: (_) => Dialog(
                  insetPadding:  EdgeInsets.all(20.w),
                  child: InteractiveViewer(
                    child: Image.network(
                      message.mediaUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            child: Image.network(
              message.mediaUrl ?? "",
              width: 220.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.image_not_supported);
              },
            ),
          ),
        );

      case "LOCATION":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
            ),
          SizedBox(height: 8.h),
            Text(
              message.locationLabel ?? "",
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          ],
        );

      default:
        return Text(
          message.content ?? "",
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.h,
            color: isMe
                ? Colors.white
                : AppColors.textPrimary,
          ),
        );
    }
  }
}


class InputBar extends StatelessWidget {
  final ChatController controller;

  const InputBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        MediaQuery.of(context).padding.bottom + 8.h,
      ),
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: AppColors.fieldBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Attachment
            IconButton(
              splashRadius: 22.r,
              icon: Icon(
                Icons.add_circle_outline,
                size: 22.sp,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                _showAttachmentSheet(context);
              },
            ),

            Expanded(
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 5,
                textCapitalization:
                    TextCapitalization.sentences,
                textInputAction: TextInputAction.send,

                onChanged: (_) {
                  controller.sendTyping();
                },

                onSubmitted: (_) {
                  controller.sendTextMessage();
                },

                decoration: InputDecoration(
                  hintText: "Type a message...".tr,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

           
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: controller.isConnected
                    ? AppColors.primary
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                splashRadius: 22,
                icon: Icon(
                  Icons.send_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
                onPressed: controller.isConnected
                    ? () async {
                        FocusScope.of(context).unfocus();
                        await controller.sendTextMessage();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Wrap(
              spacing: 20.w,
              runSpacing: 20.h,
              children: [
                _AttachmentItem(
                  icon: Icons.photo,
                  title: "Gallery".tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImageFromGallery();
                  },
                ),
                _AttachmentItem(
                  icon: Icons.camera_alt,
                  title: "Camera".tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImageFromCamera();
                  },
                ),
                _AttachmentItem(
                  icon: Icons.location_on,
                  title: "Location".tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.sendLocation();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AttachmentItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}