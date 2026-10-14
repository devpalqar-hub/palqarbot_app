import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/chats/models/chat_lsit_model.dart';
import 'package:villas_qatar/modules/chats/service/chat_controller.dart';
import 'package:villas_qatar/modules/chats/widgets/chat_listing_card.dart';
import 'package:villas_qatar/modules/chats/widgets/empty_conversation_widget.dart';
import 'package:villas_qatar/modules/chats/widgets/input_bar.dart';
import 'package:villas_qatar/modules/chats/widgets/quick_replay_Section.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/support/service/support_ticket_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class ChatStartScreen extends StatelessWidget {
  final Listing? listing;
  final Property? property;
  final String? initialMessage;
  final String? otherUserId;

  /// The person on the other end, when the caller already knows them (the
  /// chat list does). Otherwise they are worked out from the property /
  /// conversation - see [_resolvePeer].
  final String? otherUserName;
  final String? otherUserRole;

  const ChatStartScreen({
    super.key,
    this.property,
    this.initialMessage,
    this.listing,
    this.otherUserId,
    this.otherUserName,
    this.otherUserRole,
  });
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    if (initialMessage != null && controller.messageController.text.isEmpty) {
      controller.messageController.text = initialMessage!;
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            /// Messages, with the property card floating over the top.
            Expanded(
              child: GetBuilder<ChatController>(
                builder: (controller) {
                  final ChatListingSummary? summary = _listingSummary(
                    controller,
                  );
                  final double topInset = summary == null
                      ? 0
                      : ChatListingCard.height + 22;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: _buildMessages(context, controller, topInset),
                      ),
                      if (summary != null)
                        Positioned(
                          top: 10.h,
                          left: 14.w,
                          right: 14.w,
                          child: ChatListingCard(summary: summary),
                        ),
                    ],
                  );
                },
              ),
            ),

            /// QUICK REPLIES
            /// Show only when conversation has NOT started yet
            GetBuilder<ChatController>(
              builder: (chatController) {
                if (chatController.isLoading ||
                    chatController.messages.isNotEmpty) {
                  return const SizedBox.shrink();
                }

                return QuickReplySection(
                  onTap: (text) {
                    chatController.messageController.text = text;

                    /// Move cursor to end
                    chatController.messageController.selection =
                        TextSelection.collapsed(offset: text.length);
                  },
                );
              },
            ),

            Divider(height: 1.h),

            /// Input
            InputBar(controller: controller),
          ],
        ),
      ),
    );
  }

  /// Loading / empty / message list. [topInset] leaves room for the
  /// floating property card so the first message is not hidden beneath it.
  Widget _buildMessages(
    BuildContext context,
    ChatController controller,
    double topInset,
  ) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.messages.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topInset),
        child: const EmptyConversationWidget(),
      );
    }

    return ListView.builder(
      controller: controller.scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 16.w + topInset, 16.w, 16.w),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final isMe = message.sender.id == controller.myUserId;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .72,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primarySoft : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
                        bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
                        bottomRight: Radius.circular(isMe ? 4.r : 18.r),
                      ),
                      border: isMe
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe && (message.sender.name?.isNotEmpty ?? false))
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              message.sender.name!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                        _buildMessageContent(message, isMe),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Which listing the chat is about: the one we were opened with, else the
  /// listing the socket sent back when the conversation was joined.
  ChatListingSummary? _listingSummary(ChatController controller) {
    if (property != null) return ChatListingSummary.fromProperty(property!);
    if (listing != null) return ChatListingSummary.fromListing(listing!);

    final conversationListing = controller.conversation?.listing;
    if (conversationListing != null &&
        conversationListing.id.trim().isNotEmpty) {
      return ChatListingSummary.fromConversation(conversationListing);
    }

    return null;
  }

  /// Name/role of the person we are talking to. Tries, in order: what the
  /// caller passed in, the property's lister, the chat-list listing's lister,
  /// the joined conversation's lister, and finally the last message from
  /// them. Anyone who is the logged-in user is skipped (if you are the
  /// seller, the other person is the buyer).
  ({String name, String? role}) _resolvePeer(ChatController controller) {
    final String me = controller.myUserId;

    bool isOther(String id) => id.trim().isNotEmpty && id != me;

    final String passed = otherUserName?.trim() ?? '';
    if (passed.isNotEmpty) return (name: passed, role: otherUserRole);

    final owner = property?.createdBy;
    if (owner != null && isOther(owner.id)) {
      final String dealerName = owner.dealerProfile?.dealerName.trim() ?? '';
      final String name = dealerName.isNotEmpty
          ? dealerName
          : owner.name.trim();
      if (name.isNotEmpty) return (name: name, role: owner.role);
    }

    final listed = listing?.createdBy;
    if (listed != null && isOther(listed.id)) {
      final String name = listed.name?.trim() ?? '';
      if (name.isNotEmpty) return (name: name, role: listed.role);
    }

    final seller = controller.conversation?.listing.createdBy;
    if (seller != null && isOther(seller.id) && seller.name.trim().isNotEmpty) {
      return (name: seller.name.trim(), role: null);
    }

    for (final message in controller.messages.reversed) {
      if (isOther(message.sender.id) && message.sender.name.trim().isNotEmpty) {
        return (name: message.sender.name.trim(), role: message.sender.role);
      }
    }

    return (name: '', role: null);
  }

  /// USER -> "Property Owner", DEALER -> "Dealer", anything else prettified.
  String _roleLabel(String? role) {
    final String value = (role ?? '').trim();

    if (value.isEmpty) return "Property Consultant".tr;

    switch (value.toUpperCase()) {
      case "USER":
        return "Property Owner".tr;
      case "DEALER":
        return "Dealer".tr;
    }

    return value
        .replaceAll("_", " ")
        .split(" ")
        .map(
          (e) =>
              e.isEmpty ? e : e[0].toUpperCase() + e.substring(1).toLowerCase(),
        )
        .join(" ");
  }

  Widget _buildMessageContent(dynamic message, bool isMe) {
    final textColor = isMe ? Colors.black : Colors.black87;

    switch (message.type) {
      case "TEXT":
        return Text(
          message.content ?? "",
          style: TextStyle(fontSize: 14.sp, color: textColor),
        );

      case "IMAGE":
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.network(
            message.mediaUrl ?? "",
            width: 220.w,
            fit: BoxFit.cover,
            errorBuilder: (_, error, __) {
              return Text(
                "Image unavailable".tr,
                style: TextStyle(color: textColor),
              );
            },
          ),
        );

      case "LOCATION":
        final lat = message.latitude;
        final lng = message.longitude;

        return InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () async {
            final url =
                "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            width: 230.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  /// Map Preview
                  Stack(
                    children: [
                      Image.asset(
                        "assets/map_placeholder.jpg",
                        width: double.infinity,
                        height: 145.h,
                        fit: BoxFit.cover,
                      ),

                      Container(
                        height: 145.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(.15),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 15.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Location".tr,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        right: 12.w,
                        bottom: 12.h,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          elevation: 6,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final url =
                                  "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Icon(
                                Icons.navigation_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return Text(
          message.content ?? "",
          style: TextStyle(fontSize: 14.sp, color: textColor),
        );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: .5,
      shadowColor: AppColors.divider,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
      ),
      titleSpacing: 0,
      title: GetBuilder<ChatController>(
        builder: (controller) {
          final peer = _resolvePeer(controller);

          return Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primarySoft,
                child: peer.name.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : Text(
                        peer.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name.isNotEmpty ? peer.name : "Seller".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _roleLabel(peer.role),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton<String>(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
          onSelected: (value) {
            if (value == "report") {
              _showReportUserSheet();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: "report",
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.red.shade600,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "Report User".tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(width: 4.w),
      ],
    );
  }

  Future<void> _showReportUserSheet() async {
    final ChatController chatController = Get.find<ChatController>();

    /// 1. Explicitly passed other user
    final String passedUserId = otherUserId?.trim() ?? "";

    /// 2. Property owner if property exists
    final String propertyOwnerId =
        property?.createdBy.id.toString().trim() ?? "";

    /// 3. Other participant from active conversation
    final String conversationOtherUserId = chatController.otherUserId.trim();

    /// Select best available ID
    final String reportedUserId = passedUserId.isNotEmpty
        ? passedUserId
        : propertyOwnerId.isNotEmpty
        ? propertyOwnerId
        : conversationOtherUserId;

    debugPrint("========== REPORT USER ==========");

    debugPrint("MY USER ID: ${chatController.myUserId}");

    debugPrint("PASSED OTHER USER ID: $passedUserId");

    debugPrint("PROPERTY OWNER ID: $propertyOwnerId");

    debugPrint(
      "CONVERSATION OTHER USER ID: "
      "$conversationOtherUserId",
    );

    debugPrint("FINAL REPORTED USER ID: $reportedUserId");

    if (reportedUserId.isEmpty) {
      AppToast.show(
        msg: "Unable to identify the user".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    await Get.bottomSheet(
      ReportUserBottomSheet(reportedUserId: reportedUserId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      /// Important:
      /// prevents swipe-dismiss/focus conflicts while
      /// TextField is active.
      enableDrag: false,
      isDismissible: true,
    );
  }

  // Keep the remaining bottom-sheet code exactly as it is...
}

class ReportUserBottomSheet extends StatefulWidget {
  final String reportedUserId;

  const ReportUserBottomSheet({super.key, required this.reportedUserId});

  @override
  State<ReportUserBottomSheet> createState() => _ReportUserBottomSheetState();
}

class _ReportUserBottomSheetState extends State<ReportUserBottomSheet> {
  late final TextEditingController _detailsController;
  late final FocusNode _detailsFocusNode;

  String? _selectedReason;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    "Fake profile".tr,
    "Fraud or scam".tr,
    "Inappropriate behavior".tr,
    "Spam or unwanted messages".tr,
    "Misleading information".tr,
    "Other".tr,
  ];

  @override
  void initState() {
    super.initState();

    _detailsController = TextEditingController();
    _detailsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _detailsFocusNode.dispose();
    _detailsController.dispose();

    super.dispose();
  }

  Future<void> _closeSheet() async {
    /// Remove focus without using a deactivated BuildContext.
    _detailsFocusNode.unfocus();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      AppToast.show(
        msg: "Please select a reason".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_isSubmitting) return;

    /// Remove keyboard before starting async work.
    _detailsFocusNode.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final String details = _detailsController.text.trim();

    final String message = details.isNotEmpty ? details : _selectedReason!;

    final SupportTicketController support =
        Get.isRegistered<SupportTicketController>()
        ? Get.find<SupportTicketController>()
        : Get.put(SupportTicketController());

    debugPrint("========== SUBMIT REPORT USER ==========");
    debugPrint("REPORTED USER ID: ${widget.reportedUserId}");

    final result = await support.createTicket(
      category: SupportCategory.reportUser,
      subject: _selectedReason!,
      message: message,
      reportedUserId: widget.reportedUserId,
    );

    /// VERY IMPORTANT:
    /// Async operation may finish after widget is removed.
    if (!mounted) return;

    if (result != null) {
      /// Close using this sheet's own valid context.
      Navigator.of(context).pop();

      /// Show toast after this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppToast.show(
          msg: "Report submitted successfully".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });

      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    AppToast.show(
      msg: support.createError.isNotEmpty
          ? support.createError
          : "Unable to submit report".tr,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          18.h,
          20.w,
          MediaQuery.of(context).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // DRAG HANDLE
              // ==================================================
              Center(
                child: Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // ==================================================
              // HEADER
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Report User".tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  InkWell(
                    borderRadius: BorderRadius.circular(50.r),
                    onTap: _isSubmitting ? null : _closeSheet,
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 19.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              Text(
                "Tell us why you're reporting this user.".tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 22.h),

              // ==================================================
              // REASON TITLE
              // ==================================================
              Text(
                "Reason for Report".tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 12.h),

              // ==================================================
              // REASON OPTIONS
              // ==================================================
              // ==================================================
              // REASON OPTIONS - COLUMN LIST
              // ==================================================
              Column(
                children: _reasons.map((reason) {
                  final bool selected = _selectedReason == reason;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: _isSubmitting
                          ? null
                          : () {
                              _detailsFocusNode.unfocus();

                              setState(() {
                                _selectedReason = reason;
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.fieldBorder,
                            width: selected ? 1.2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // =====================================
                            // REASON TEXT
                            // =====================================
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // =====================================
                            // RADIO ICON
                            // =====================================
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                selected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                key: ValueKey(selected),
                                size: 21.sp,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ==================================================
              // ADDITIONAL DETAILS
              // ==================================================
              Row(
                children: [
                  Text(
                    "Additional Details".tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(width: 5.w),

                  Text(
                    "(Optional)".tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              TextField(
                controller: _detailsController,
                focusNode: _detailsFocusNode,
                maxLines: 4,
                maxLength: 500,
                enabled: !_isSubmitting,
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Describe the issue".tr,
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.fieldBorder),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.fieldBorder),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // ==================================================
              // INFO BOX
              // ==================================================
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(.12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 9.w),

                    Expanded(
                      child: Text(
                        "Your report will be reviewed by our support team.".tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ==================================================
              // SUBMIT BUTTON
              // Same style as Book Visit
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,

                  style: ElevatedButton.styleFrom(
                    elevation: 0,

                    backgroundColor: AppColors.primary,

                    disabledBackgroundColor: AppColors.primary.withOpacity(.6),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),

                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "Submit Report".tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
