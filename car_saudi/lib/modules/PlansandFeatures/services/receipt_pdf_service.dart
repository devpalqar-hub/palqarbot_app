import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:villas_qatar/modules/PlansandFeatures/model/myfeatured_property.dart';

// ============================================================
// RECEIPT PDF SERVICE
//
// BUILDS A "PAYMENT RECEIPT" PDF FOR A FEATURED-PROPERTY
// PURCHASE, STYLED TO MATCH THE VILLAS QATAR RECEIPT LAYOUT.
// ============================================================

class ReceiptPdfService {
  ReceiptPdfService._();

  static const PdfColor _maroon = PdfColor.fromInt(0xFF8A1538);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD9B27C);
  static const PdfColor _ink = PdfColor.fromInt(0xFF202020);
  static const PdfColor _grey = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _faint = PdfColor.fromInt(0xFFEDEDED);
  static const PdfColor _paper = PdfColor.fromInt(0xFFFDFBF8);
  static const PdfColor _green = PdfColor.fromInt(0xFF16A34A);
  static const PdfColor _greenBg = PdfColor.fromInt(0xFFE7F6EC);
  static const PdfColor _redBg = PdfColor.fromInt(0xFFFCE8E8);
  static const PdfColor _red = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _orangeBg = PdfColor.fromInt(0xFFFEF3E2);
  static const PdfColor _orange = PdfColor.fromInt(0xFFB45309);

  // ============================================================
  // BUILD
  // ============================================================

  static Future<Uint8List> build(
    MyFeaturedProperty entry,
  ) async {
    final pw.Document doc = pw.Document();

    final Uint8List logoBytes = await _loadLogo();
    final pw.MemoryImage? logo =
        logoBytes.isEmpty ? null : pw.MemoryImage(logoBytes);

    final String status = _statusLabel(entry);
    final PdfColor statusColor = _statusColor(entry);
    final PdfColor statusBg = _statusBg(entry);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Container(
            color: _paper,
            padding: const pw.EdgeInsets.all(18),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(logo),

                pw.SizedBox(height: 4),

                pw.Container(height: 2, color: _gold),

                pw.SizedBox(height: 18),

                _receiptMeta(entry),

                pw.SizedBox(height: 16),

                _paymentDetailsBox(
                  entry: entry,
                  status: status,
                  statusColor: statusColor,
                  statusBg: statusBg,
                ),

                pw.SizedBox(height: 16),

                _totalPaidBar(entry),

                pw.SizedBox(height: 16),

                _thankYouBox(),

                pw.Spacer(),

                _footerBar(),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // ============================================================
  // HEADER
  // ============================================================

  static pw.Widget _header(pw.MemoryImage? logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) ...[
          pw.Image(logo, width: 44, height: 44),
          pw.SizedBox(width: 10),
        ],

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Villas Qatar',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _maroon,
              ),
            ),

            pw.Text(
              'FIND YOUR PERFECT HOME',
              style: pw.TextStyle(
                fontSize: 7,
                color: _gold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        pw.Spacer(),

        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: pw.BoxDecoration(
            color: _maroon,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            'PAYMENT RECEIPT',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: .8,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECEIPT NO / DATE
  // ============================================================

  static pw.Widget _receiptMeta(MyFeaturedProperty entry) {
    final String date = entry.createdAt != null
        ? DateFormat('d/M/yyyy').format(entry.createdAt!)
        : '-';

    return pw.Row(
      children: [
        _metaTile(
          label: 'Receipt No.',
          value: entry.receiptNumber,
        ),

        pw.Container(
          width: 1,
          height: 30,
          margin: const pw.EdgeInsets.symmetric(horizontal: 18),
          color: _faint,
        ),

        _metaTile(
          label: 'Date',
          value: date,
        ),
      ],
    );
  }

  static pw.Widget _metaTile({
    required String label,
    required String value,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: _grey),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _maroon,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT DETAILS BOX
  // ============================================================

  static pw.Widget _paymentDetailsBox({
    required MyFeaturedProperty entry,
    required String status,
    required PdfColor statusColor,
    required PdfColor statusBg,
  }) {
    final String displayLocation =
        entry.plan.displayLocationsLabel.isNotEmpty
            ? entry.plan.displayLocationsLabel
            : (entry.locationLabel.isNotEmpty
                ? entry.locationLabel
                : '-');

    final List<_ReceiptRow> rows = [
      _ReceiptRow.badge('Transaction Status', status, statusColor, statusBg),
      _ReceiptRow('Transaction ID', entry.transactionId),
      _ReceiptRow(
        'Plan Name',
        entry.plan.name.isNotEmpty ? entry.plan.name : '-',
      ),
      _ReceiptRow(
        'Property',
        entry.listing.propertyName.isNotEmpty
            ? entry.listing.propertyName
            : '-',
      ),
      _ReceiptRow('Display Location', displayLocation),
      _ReceiptRow('Start Date', entry.formattedStartDate),
      _ReceiptRow('End Date', entry.formattedEndDate),
    ];

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _faint),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _maroon,
              letterSpacing: .6,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Divider(color: _faint, thickness: 1),

          pw.SizedBox(height: 4),

          for (final row in rows) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 140,
                    child: pw.Text(
                      row.label,
                      style: pw.TextStyle(fontSize: 10, color: _grey),
                    ),
                  ),

                  pw.Expanded(
                    child: row.isBadge
                        ? pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: row.badgeBg,
                                borderRadius: pw.BorderRadius.circular(20),
                              ),
                              child: pw.Text(
                                row.value,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: row.badgeColor,
                                ),
                              ),
                            ),
                          )
                        : pw.Text(
                            row.value,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: _ink,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            if (row != rows.last)
              pw.Divider(color: _faint, thickness: .6),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL PAID BAR
  // ============================================================

  static pw.Widget _totalPaidBar(MyFeaturedProperty entry) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: pw.BoxDecoration(
        color: _maroon,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL PAID',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: .8,
            ),
          ),

          pw.Text(
            entry.formattedPaidAmount,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THANK YOU
  // ============================================================

  static pw.Widget _thankYouBox() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF7F1EC),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Thank you for your purchase!',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _maroon,
            ),
          ),

          pw.SizedBox(height: 3),

          pw.Text(
            'We appreciate your trust in Villas Qatar.',
            style: pw.TextStyle(fontSize: 9.5, color: _grey),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            'If you have any questions, please contact '
            'support@villasqatar.com',
            style: pw.TextStyle(fontSize: 9.5, color: _grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  static pw.Widget _footerBar() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: pw.BoxDecoration(
        color: _maroon,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Center(
        child: pw.Text(
          'www.villasqatar.com',
          style: pw.TextStyle(
            fontSize: 9.5,
            color: PdfColors.white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  static String _statusLabel(MyFeaturedProperty entry) {
    if (entry.isFailed) {
      return 'FAILED';
    }

    if (entry.isPaid) {
      return 'PAID';
    }

    return entry.paymentStatusLabel.isNotEmpty
        ? entry.paymentStatusLabel.toUpperCase()
        : 'PENDING';
  }

  static PdfColor _statusColor(MyFeaturedProperty entry) {
    if (entry.isFailed) {
      return _red;
    }

    if (entry.isPaid) {
      return _green;
    }

    return _orange;
  }

  static PdfColor _statusBg(MyFeaturedProperty entry) {
    if (entry.isFailed) {
      return _redBg;
    }

    if (entry.isPaid) {
      return _greenBg;
    }

    return _orangeBg;
  }

  // ============================================================
  // LOGO
  // ============================================================

  static Future<Uint8List> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/Logo/logo.png',
      );

      return data.buffer.asUint8List();
    } catch (_) {
      return Uint8List(0);
    }
  }
}

// ============================================================
// ROW MODEL
// ============================================================

class _ReceiptRow {
  final String label;
  final String value;
  final bool isBadge;
  final PdfColor badgeColor;
  final PdfColor badgeBg;

  _ReceiptRow(this.label, this.value)
      : isBadge = false,
        badgeColor = PdfColors.black,
        badgeBg = PdfColors.white;

  _ReceiptRow.badge(
    this.label,
    this.value,
    this.badgeColor,
    this.badgeBg,
  ) : isBadge = true;
}
