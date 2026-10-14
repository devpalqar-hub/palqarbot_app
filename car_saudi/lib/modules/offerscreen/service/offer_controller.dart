import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MakeOfferController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final offerAmountController = TextEditingController();
  final downPaymentController = TextEditingController();
  final messageController = TextEditingController();
  final closingDateController = TextEditingController();

  final currencies = ["QAR", "USD", "AED"];

  final financingTypes = ["Cash", "Mortgage"];

  String selectedCurrency = "QAR";
  String selectedFinancing = "Cash";

  DateTime? selectedDate;

  @override
  void onClose() {
    offerAmountController.dispose();
    downPaymentController.dispose();
    messageController.dispose();
    closingDateController.dispose();
    super.onClose();
  }

  void changeCurrency(String? value) {
    if (value == null) return;
    selectedCurrency = value;
    update();
  }

  void changeFinancing(String? value) {
    if (value == null) return;
    selectedFinancing = value;
    update();
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      selectedDate = picked;

      closingDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";

      update();
    }
  }

  void submitOffer() {
    if (!formKey.currentState!.validate()) return;

    final body = {
      "offerAmount": offerAmountController.text,
      "currency": selectedCurrency,
      "downPayment": downPaymentController.text,
      "financing": selectedFinancing,
      "closingDate": closingDateController.text,
      "message": messageController.text,
    };

    debugPrint(body.toString());

    /// TODO
    /// Call Repository API
  }
}
