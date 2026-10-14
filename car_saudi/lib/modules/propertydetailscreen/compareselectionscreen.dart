// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:villas_qatar/Core/constants/app_colors.dart';
// import 'package:villas_qatar/modules/propertydetailscreen/property_comparison_screen.dart';
// import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

// class CompareSelectionScreen extends StatefulWidget {
//   final Property currentProperty;
//   final List<Property> properties;

//   const CompareSelectionScreen({
//     super.key,
//     required this.currentProperty,
//     required this.properties,
//   });

//   @override
//   State<CompareSelectionScreen> createState() =>
//       _CompareSelectionScreenState();
// }

// class _CompareSelectionScreenState
//     extends State<CompareSelectionScreen> {
//   final List<Property> selectedProperties = [];

//   bool isSelected(Property property) {
//     return selectedProperties.any((e) => e.id == property.id);
//   }

//   void toggleSelection(Property property) {
//     setState(() {
//       if (isSelected(property)) {
//         selectedProperties.removeWhere((e) => e.id == property.id);
//       } else {
//         if (selectedProperties.length < 4) {
//           selectedProperties.add(property);
//         }
//       }
//     });
//   }

//   String formatPrice(double price) {
//     return "${"QAR".tr} ${price.toStringAsFixed(0)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Compare Properties"),
//       ),

//       body: ListView.separated(
//         itemCount: widget.properties.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final property = widget.properties[index];

//           return CheckboxListTile(
//             value: isSelected(property),
//             onChanged: (_) => toggleSelection(property),
//             controlAffinity: ListTileControlAffinity.leading,

//             title: Text(
//               property.propertyName,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "${property.areaName}, ${property.municipality.name}",
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   formatPrice(property.price),
//                   style: const TextStyle(
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),

//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ElevatedButton(
//             onPressed: selectedProperties.length >= 2
//                 ? () {
//                     Get.to(
//                       () => PropertyComparisonScreen(
//                         currentProperty: widget.currentProperty,
//                         compareProperties: selectedProperties,
//                       ),
//                     );
//                   }
//                 : null,
//             child: Text(
//               "Compare (${selectedProperties.length})",
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }