import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/receipt_data.dart';

class PdfService {
  Future<void> printReceipts(
    List<ReceiptData> receipts, {
    int printScale = 70,
    double paperWidthMm = 210,
    double paperHeightMm = 330,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) => buildPdfBytes(receipts, printScale: printScale, paperWidthMm: paperWidthMm, paperHeightMm: paperHeightMm),
      name: receipts.length > 1 ? 'Batch_Kwitansi' : 'Kwitansi',
    );
  }

  Future<Uint8List> buildPdfBytes(
    List<ReceiptData> receipts, {
    int printScale = 70,
    double paperWidthMm = 210,
    double paperHeightMm = 330,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.times();
    final bold = pw.Font.timesBold();

    final defaultMainBytes = await _loadAssetBytes('assets/LogoMain.jpg');
    final defaultSignBytes = await _loadAssetBytes('assets/deafult_ttd.png');
    final defaultCapBytes = await _loadAssetBytes('assets/cap_ttd.png');

    final format = PdfPageFormat(paperWidthMm * PdfPageFormat.mm, paperHeightMm * PdfPageFormat.mm);

    for (var i = 0; i < receipts.length;) {
      final top = receipts[i];
      final canCompactTop = _canFitHalfPage(top);

      if (!canCompactTop) {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(8),
            build: (context) => _receiptWidget(top, font, bold, printScale, defaultMainBytes, defaultSignBytes, defaultCapBytes),
          ),
        );
        i += 1;
        continue;
      }

      final hasBottom = i + 1 < receipts.length;
      final bottom = hasBottom ? receipts[i + 1] : null;
      final canCompactBottom = bottom != null && _canFitHalfPage(bottom);

      if (canCompactBottom) {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(8),
            build: (context) => pw.Column(
              children: [
                pw.Expanded(child: _receiptWidget(top, font, bold, printScale, defaultMainBytes, defaultSignBytes, defaultCapBytes)),
                pw.SizedBox(height: 6),
                pw.Container(height: 1, color: PdfColors.grey500),
                pw.SizedBox(height: 6),
                pw.Expanded(child: _receiptWidget(bottom, font, bold, printScale, defaultMainBytes, defaultSignBytes, defaultCapBytes)),
              ],
            ),
          ),
        );
        i += 2;
      } else {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(8),
            build: (context) => _receiptWidget(top, font, bold, printScale, defaultMainBytes, defaultSignBytes, defaultCapBytes),
          ),
        );
        i += 1;
      }
    }

    return pdf.save();
  }

  pw.Widget _receiptWidget(
    ReceiptData receipt,
    pw.Font font,
    pw.Font bold,
    int printScale,
    Uint8List? defaultMainBytes,
    Uint8List? defaultSignBytes,
    Uint8List? defaultCapBytes,
  ) {
    final currency = NumberFormat('#,##0.00', 'id_ID');
    final scale = (printScale.clamp(90, 160)) / 100.0;
    final f8 = 9.5 * scale;
    final f9 = 10.5 * scale;
    final f14 = 16.5 * scale;

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 54, height: 44, child: _pdfLogo(receipt.logoMainPath, receipt.logoMainScale, defaultMainBytes)),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Center(child: pw.Text(receipt.companyName, style: pw.TextStyle(font: bold, fontSize: f14 * 1.5, color: PdfColors.red700))),
                    if (receipt.subName.trim().isNotEmpty)
                      pw.Center(child: pw.Text(receipt.subName, style: pw.TextStyle(font: bold, fontSize: f9 * 1.5, color: PdfColors.red700))),
                    if (receipt.slogan.trim().isNotEmpty)
                      pw.Center(child: pw.Text(receipt.slogan, style: pw.TextStyle(font: bold, fontSize: f9))),
                    ...receipt.addressLines.where((e) => e.trim().isNotEmpty).map((e) => pw.Center(child: pw.Text(e, style: pw.TextStyle(font: font, fontSize: f8)))),
                  ],
                ),
              ),
              pw.SizedBox(
                width: 210,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Rembang, ${receipt.date}', style: pw.TextStyle(font: font, fontSize: f8), textAlign: pw.TextAlign.right),
                    pw.SizedBox(height: 3),
                    pw.RichText(
                      textAlign: pw.TextAlign.right,
                      text: pw.TextSpan(
                        style: pw.TextStyle(font: font, fontSize: f8),
                        children: [
                          const pw.TextSpan(text: 'Kepada Yth: '),
                          pw.TextSpan(text: receipt.recipientName.toUpperCase(), style: pw.TextStyle(font: bold, fontSize: f8)),
                        ],
                      ),
                    ),
                    if (receipt.recipientLine2.isNotEmpty)
                      pw.Text(
                        receipt.recipientLine2.toUpperCase(),
                        style: pw.TextStyle(font: bold, fontSize: f8),
                        textAlign: pw.TextAlign.right,
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text('KWITANSI', style: pw.TextStyle(font: bold, fontSize: f14, letterSpacing: 1.8 * scale)),
          ),
          pw.SizedBox(height: 2),
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 20 * scale),
            child: pw.Text('No : ${receipt.no}', style: pw.TextStyle(font: font, fontSize: f9)),
          ),
          pw.SizedBox(height: 2),
          pw.Table(
            border: pw.TableBorder.all(width: .85),
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(5),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(children: [
                _cell('JUMLAH', bold, f8, center: true),
                _cell('NAMA BARANG', bold, f8, center: true),
                _cell('HARGA', bold, f8, center: true),
                _cell('TOTAL', bold, f8, center: true),
              ]),
              ...receipt.items.map((e) => pw.TableRow(children: [
                    _cell('${e.quantity}', font, f8, center: true),
                    _cell('${e.name}\n${e.description}\n\nPengirim:\n${receipt.senderDetails.join('\n')}', bold, f8),
                    _cell('Rp. ${currency.format(e.price)}', font, f8, center: true),
                    _cell('Rp. ${currency.format(e.total)}', font, f8, center: true),
                  ])),
              pw.TableRow(children: [
                _cell('', font, f8),
                _cell('', font, f8),
                _cell('', font, f8),
                _cell('Rp. ${currency.format(receipt.grandTotal)}', bold, f8, center: true),
              ]),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              children: [
                pw.Text(
                  receipt.companyName.toUpperCase(),
                  style: pw.TextStyle(font: bold, fontSize: f9, fontStyle: pw.FontStyle.italic),
                ),
                pw.SizedBox(height: 2),
                pw.SizedBox(
                  width: 66,
                  height: 48,
                  child: pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      _pdfLogo(receipt.logoSignaturePath, receipt.logoSignatureScale, defaultSignBytes),
                      if (receipt.capSignatureEnabled)
                        _pdfLogo(receipt.capSignaturePath, receipt.logoSignatureScale, defaultCapBytes),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8 * scale),
                pw.Text(
                  receipt.signer,
                  style: pw.TextStyle(font: bold, fontSize: f9, decoration: pw.TextDecoration.underline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canFitHalfPage(ReceiptData receipt) {
    final itemCount = receipt.items.length;
    final itemLines = receipt.items.fold<int>(0, (sum, item) {
      final base = 2; // nama + harga row approx
      final descLines = _estimateLines(item.description, 44);
      return sum + base + descLines;
    });

    final senderLines = _estimateLines(receipt.senderDetails.join('\n'), 38);
    final headerLines = 7 + receipt.addressLines.length;
    final totalScore = headerLines + itemLines + senderLines + (itemCount * 2);

    // heuristic empiris: di atas ini biasanya kepotong jika dipaksa 2-up
    return totalScore <= 44;
  }

  int _estimateLines(String text, int charsPerLine) {
    if (text.trim().isEmpty) return 0;
    final rows = text.split('\n');
    var lines = 0;
    for (final row in rows) {
      final len = row.trim().length;
      lines += (len / charsPerLine).ceil().clamp(1, 99);
    }
    return lines;
  }

  pw.Widget _pdfLogo(String? path, int scalePercent, Uint8List? fallbackBytes) {
    Uint8List? bytes;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        bytes = file.readAsBytesSync();
      }
    }
    bytes ??= fallbackBytes;
    if (bytes == null) return pw.SizedBox();

    final normalized = scalePercent.clamp(1, 100) / 100.0;
    final factor = 0.4 + (normalized * 0.9);

    return pw.Transform.scale(
      scale: factor,
      child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
    );
  }

  Future<Uint8List?> _loadAssetBytes(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  pw.Widget _cell(String text, pw.Font font, double fontSize, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: fontSize),
      ),
    );
  }
}
