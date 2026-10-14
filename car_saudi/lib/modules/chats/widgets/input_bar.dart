import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/chats/service/chat_controller.dart';

class InputBar extends StatelessWidget {
  final ChatController controller;

  const InputBar({super.key, required this.controller});

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
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: AppColors.fieldBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12.r,
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

            /// Message Field
            Expanded(
              child: TextField(
                controller: controller.messageController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Type a message...".tr,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            /// Emoji
            IconButton(
              splashRadius: 22.r,
              icon: Icon(
                Icons.emoji_emotions_outlined,
                size: 22.sp,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),

            /// Send Button
            Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                splashRadius: 22.r,
                icon: Icon(
                  Icons.send_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (controller.messageController.text.trim().isEmpty) {
                    return;
                  }

                  await controller.sendTextMessage();
                },
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: SizedBox(
              height: 85.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      borderRadius: BorderRadius.circular(14.r),
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
              child: Icon(icon, color: AppColors.primary, size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
