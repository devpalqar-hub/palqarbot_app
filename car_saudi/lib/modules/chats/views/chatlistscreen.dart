import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/chats/models/chat_lsit_model.dart';
import 'package:villas_qatar/modules/chats/service/chat_list_controller.dart';
import 'package:villas_qatar/modules/chats/views/chat_startscreen.dart';
import 'package:villas_qatar/modules/sellerpropertyscreen/views/seller_property_screen.dart';
import 'package:villas_qatar/modules/visits/view/visit_list_screen.dart';
import '../service/chat_controller.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatListController controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());
    // Controller instance persists across navigations (GetX reuses it),
    // so onInit()'s one-time fetch won't pick up chats started elsewhere.
    // Re-fetch every time this screen is entered.
    controller.fetchConversations();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          "My Chats".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "My Visits".tr,
            onPressed: () {
              Get.to(() => const VisitListScreen());
            },
            icon: const Icon(
              Icons.location_city_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Column(
            children: [
              Container(
                height: 38.h,
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: TextField(
                  onChanged: controller.searchConversation,
                  decoration: InputDecoration(
                    hintText: "Search by property or seller".tr,
                    prefixIcon: Icon(Icons.search, color: AppColors.hintGrey),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              Expanded(
                child: GetBuilder<ChatListController>(
                  builder: (controller) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.filteredConversations.isEmpty) {
                      return Center(
                        child: Text(
                          "No Conversations".tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refreshList,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        itemCount: controller.filteredConversations.length,
                        itemBuilder: (_, index) {
                          final conversation =
                              controller.filteredConversations[index];

                          final seller = conversation.participants.firstWhere(
                            (e) => e.user.id != conversation.user.id,
                          );

                          return _ConversationTile(
                            conversation: conversation,
                            participant: seller,
                            onTap: () {
                              debugPrint("🔥🔥🔥 CHAT TILE CLICKED 🔥🔥🔥");
                              debugPrint("CONVERSATION ID: ${conversation.id}");
                              debugPrint(
                                "LISTING ID: ${conversation.listing.id}",
                              );
                              debugPrint(
                                "CONTACT PHONE: '${conversation.listing.contactPhone}'",
                              );

                              if (Get.isRegistered<ChatController>()) {
                                Get.delete<ChatController>(force: true);
                              }

                              Get.put(
                                ChatController(
                                  listingId: conversation.listing.id,
                                  initialConversationId: conversation.id,
                                ),
                              );

                              Get.to(
                                () => ChatStartScreen(
                                  listing: conversation.listing,
                                  otherUserId: seller.userId,
                                  otherUserName: seller.user.name,
                                  otherUserRole: seller.user.role,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatListModel conversation;
  final Participant participant;
  final VoidCallback onTap;

  const _ConversationTile({
    super.key,
    required this.conversation,
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final message = conversation.lastMessage;

    final String propertyName =
        conversation.listing.propertyName.trim().isNotEmpty
        ? conversation.listing.propertyName.trim()
        : "Property".tr;

    final String sellerName =
        conversation.otherParticipant?.user.name?.trim().isNotEmpty == true
        ? conversation.otherParticipant!.user.name!.trim()
        : "Seller".tr;

    final String propertyType = conversation.listing.type?.title.trim() ?? "";

    final String purpose = conversation.listing.purpose.trim();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xffECECEC)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.025),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // PROPERTY IMAGE
                // ============================================
                ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: SizedBox(
                    width: 72.w,
                    height: 76.h,
                    child: conversation.listing.image.isNotEmpty
                        ? Image.network(
                            conversation.listing.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) {
                              debugPrint("Image Error: $error".tr);

                              return _placeholder();
                            },
                          )
                        : _placeholder(),
                  ),
                ),

                SizedBox(width: 11.w),

                // ============================================
                // DETAILS
                // ============================================
                Expanded(
                  child: SizedBox(
                    height: 76.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ====================================
                        // PROPERTY NAME + TIME
                        // PROPERTY NAME IS PRIMARY
                        // ====================================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                propertyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff202020),
                                ),
                              ),
                            ),

                            SizedBox(width: 8.w),

                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Text(
                                _formatTime(conversation.updatedAt),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff929292),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            if (propertyType.isNotEmpty)
                              _smallTag(propertyType),

                            if (propertyType.isNotEmpty && purpose.isNotEmpty)
                              SizedBox(width: 5.w),
                          ],
                        ),

                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 12.sp,
                              color: const Color(0xff999999),
                            ),

                            SizedBox(width: 5.w),

                            Expanded(
                              child: Text(
                                message?.content ?? "No messages yet".tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  height: 1.2,
                                  color: const Color(0xff6F6F6F),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Container(
                              width: 18.w,
                              height: 18.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: 11.sp,
                                color: AppColors.primary,
                              ),
                            ),

                            SizedBox(width: 5.w),

                            Text(
                              "Chat with ".tr,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: const Color(0xff999999),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Get.to(
                                    () => SellerPropertiesScreen(
                                      sellerId: conversation
                                          .otherParticipant!
                                          .user
                                          .id,
                                      sellerName: sellerName,
                                    ),
                                  );
                                },
                                child: Text(
                                  sellerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),

                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16.sp,
                              color: const Color(0xffAAAAAA),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.06),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        _formatLabel(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72.w,
      height: 76.h,
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: Icon(
        Icons.home_work_outlined,
        color: AppColors.primary,
        size: 25.sp,
      ),
    );
  }

  String _formatLabel(String value) {
    if (value.trim().isEmpty) return "";

    return value
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .where((word) => word.isNotEmpty)
        .map((word) => "${word[0].toUpperCase()}${word.substring(1)}")
        .join(" ").tr;
  }

  String _formatTime(DateTime date) {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime messageDate = DateTime(date.year, date.month, date.day);

    final int difference = today.difference(messageDate).inDays;

    // Today
    if (difference == 0) {
      return DateFormat('hh:mm a').format(date);
    }

    // Yesterday
    if (difference == 1) {
      return 'Yesterday'.tr;
    }

    // Within last 7 days
    if (difference > 1 && difference < 7) {
      return DateFormat('EEE').format(date);
    }

    // Same year -> 21 Jul
    if (date.year == now.year) {
      return DateFormat('dd MMM').format(date);
    }

    // Older year -> 21 Jul 2025
    return DateFormat('dd MMM yyyy').format(date);
  }
}
