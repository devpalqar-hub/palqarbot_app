import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PropertyLocationCard extends StatefulWidget {
  final Property property;

  const PropertyLocationCard({super.key, required this.property});

  static const Color primary = Color(0xFFA60F46);

  @override
  State<PropertyLocationCard> createState() => _PropertyLocationCardState();
}

class _PropertyLocationCardState extends State<PropertyLocationCard> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final lat = widget.property.latitude;
    final lng = widget.property.longitude;

    final html =
        '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}
iframe {
  border: 0;
  width: 100%;
  height: 100%;
}
</style>
</head>
<body>
<iframe
    loading="lazy"
    allowfullscreen
    src="https://maps.google.com/maps?q=$lat,$lng(Property)&z=16&output=embed">
</iframe>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE7E7E7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xff202124),
            ),
          ),

          SizedBox(height: 10.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: SizedBox(
              height: 160.h,
              width: double.infinity,
              child: WebViewWidget(controller: _controller),
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: PropertyLocationCard.primary,
                size: 16.sp,
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  "${widget.property.areaName}, ${widget.property.municipality.name}, ${widget.property.country}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xff555555),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=${widget.property.latitude},${widget.property.longitude}",
                );

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.map_outlined),
              label: Text("View on Google Maps".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: PropertyLocationCard.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            "Nearby Places".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xff202124),
            ),
          ),

          SizedBox(height: 14.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.property.nearbyTags.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1, // <-- Square
            ),
            itemBuilder: (_, index) {
              return _NearbyCard(item: widget.property.nearbyTags[index]);
            },
          ),
        ],
      ),
    );
  }
}
  
  class _NearbyCard extends StatelessWidget {
  final NearbyTag item;

  const _NearbyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xffECECEC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: (item.image ?? "").isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.network(
                        item.image!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.place,
                        color: PropertyLocationCard.primary,
                        size: 28.sp,
                      ),
                    ),
            ),
            SizedBox(height: 4.h),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ===================================================================
// SIMPLE MAP BACKGROUND
// Remove this if you use GoogleMap/static map image.
// ===================================================================

class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final Paint smallRoadPaint = Paint()
      ..color = Colors.white.withOpacity(.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * .25),
      Offset(size.width, size.height * .75),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * .2, 0),
      Offset(size.width * .55, size.height),
      roadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * .75),
      Offset(size.width, size.height * .35),
      smallRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * .72, 0),
      Offset(size.width * .85, size.height),
      smallRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
