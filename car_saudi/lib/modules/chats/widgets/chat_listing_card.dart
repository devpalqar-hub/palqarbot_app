import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/modules/chats/models/chat_lsit_model.dart';
import 'package:villas_qatar/modules/chats/models/conversation_model.dart'
    as convo;
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertydetailscreen/widget/pd_tokens.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

/// The bits of a listing the chat header needs. The chat can be opened with
/// a full [Property] (from the property page), a chat-list [Listing], or -
/// once the socket has joined - the conversation's own listing, so each has
/// a named constructor that maps into this one shape.
class ChatListingSummary {
  final String id;
  final String name;
  final String location;
  final String? photoUrl;
  final num price;
  final bool isRent;

  const ChatListingSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.photoUrl,
    required this.price,
    required this.isRent,
  });

  static String _join(Iterable<String> parts) =>
      parts.where((e) => e.trim().isNotEmpty).join(', ');

  factory ChatListingSummary.fromProperty(Property p) {
    final photos = p.sortedPhotos;

    return ChatListingSummary(
      id: p.id,
      name: p.propertyName,
      location: _join([p.areaName, p.municipality.name]),
      photoUrl: photos.isEmpty ? null : photos.first.url,
      price: p.price,
      isRent: p.purpose.toUpperCase() == 'RENT',
    );
  }

  factory ChatListingSummary.fromListing(Listing l) {
    return ChatListingSummary(
      id: l.id,
      name: l.propertyName,
      location: _join([l.areaName, l.municipality]),
      photoUrl: l.photos.isEmpty ? null : l.photos.first.url,
      price: l.price,
      isRent: l.purpose.toUpperCase() == 'RENT',
    );
  }

  factory ChatListingSummary.fromConversation(convo.ListingModel l) {
    final photos = [...l.photos]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ChatListingSummary(
      id: l.id,
      name: l.propertyName,
      location: _join([l.areaName, l.municipality.name]),
      photoUrl: photos.isEmpty ? null : photos.first.url,
      price: l.price,
      isRent: l.purpose.toUpperCase() == 'RENT',
    );
  }
}

/// Floating "this chat is about..." card pinned to the top of the chat.
/// Tapping it opens the property page.
class ChatListingCard extends StatelessWidget {
  /// Fixed layout height in logical pixels (deliberately not ScreenUtil
  /// scaled, so it always matches the room the message list reserves at the
  /// top for it).
  static const double height = 84;
  static const double _photoSize = 62;

  final ChatListingSummary summary;

  const ChatListingCard({super.key, required this.summary});

  void _openProperty() {
    if (summary.id.trim().isEmpty) return;

    Get.to(() => PropertyDetailsScreen(propertyId: summary.id));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProperty,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: PD.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .09),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _photo(),
              SizedBox(width: 12.w),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: c.maxWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          if (summary.location.isNotEmpty) ...[
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12.sp,
                                  color: AppColors.inkFaint,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    summary.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5.sp,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .3),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo() {
    final Widget placeholder = Container(
      width: _photoSize,
      height: _photoSize,
      color: PD.line,
      child: Icon(Icons.home_work_outlined, size: 24.sp, color: Colors.grey),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: (summary.photoUrl ?? '').isEmpty
          ? placeholder
          : Image.network(
              summary.photoUrl!,
              width: _photoSize,
              height: _photoSize,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
