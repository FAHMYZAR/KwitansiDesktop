import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/receipt_data.dart';

class ReceiptPreviewCard extends StatelessWidget {
  const ReceiptPreviewCard({super.key, required this.data});

  final ReceiptData data;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'id_ID');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black87, fontFamily: 'Times New Roman'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 62,
                  child: _logo(data.logoMainPath, data.logoMainScale, 'assets/LogoMain.jpg'),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(data.companyName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC00000), fontSize: 28)),
                      if (data.subName.trim().isNotEmpty)
                        Text(data.subName, style: const TextStyle(color: Color(0xFFC00000), fontSize: 16, fontWeight: FontWeight.w700)),
                      if (data.slogan.trim().isNotEmpty)
                        Text(data.slogan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.center),
                      if (data.addressLines.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            children: data.addressLines
                                .where((e) => e.trim().isNotEmpty)
                                .map((e) => Text(e, style: const TextStyle(fontSize: 9), textAlign: TextAlign.center))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rembang, ${data.date}', textAlign: TextAlign.end),
                      const SizedBox(height: 4),
                      RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontFamily: 'Times New Roman'),
                          children: [
                            const TextSpan(text: 'Kepada Yth: '),
                            TextSpan(text: data.recipientName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      if (data.recipientLine2.isNotEmpty)
                        Text(data.recipientLine2.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Center(child: Text('KWITANSI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 3))),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 3, bottom: 4),
              child: Text('No : ${data.no}'),
            ),
            Table(
              border: TableBorder.all(color: Colors.black, width: 1.1),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(6),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                _header(),
                ...data.items.map((e) => TableRow(children: [
                      _cell('${e.quantity}', align: TextAlign.center),
                      _cell('${e.name}\n${e.description}\n\nPengirim:\n${data.senderDetails.join('\n')}', align: TextAlign.left, bold: true),
                      _cell('Rp. ${currency.format(e.price)}', align: TextAlign.center),
                      _cell('Rp. ${currency.format(e.total)}', align: TextAlign.center),
                    ])),
                TableRow(children: [
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  _cell(''),
                  _cell('Rp. ${currency.format(data.grandTotal)}', align: TextAlign.center, bold: true),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 170,
                child: Column(
                  children: [
                    const Text('ALYAA FLORIST', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 72,
                      height: 56,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _logo(data.logoSignaturePath, data.logoSignatureScale, 'assets/deafult_ttd.png'),
                          if (data.capSignatureEnabled) _logo(data.capSignaturePath, data.logoSignatureScale, 'assets/cap_ttd.png'),
                        ],
                      ),
                    ),
                    Text(data.signer, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  TableRow _header() => const TableRow(
        children: [
          _CellWidget('JUMLAH', true, TextAlign.center),
          _CellWidget('NAMA BARANG', true, TextAlign.center),
          _CellWidget('HARGA', true, TextAlign.center),
          _CellWidget('TOTAL', true, TextAlign.center),
        ],
      );

  Widget _cell(String text, {TextAlign align = TextAlign.left, bool bold = false}) {
    return _CellWidget(text, bold, align);
  }

  Widget _logo(String? path, int scalePercent, String fallbackAsset) {
    final normalized = scalePercent.clamp(1, 100) / 100.0;
    final scale = 0.4 + (normalized * 0.9);

    Widget image;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        image = Image.file(file, fit: BoxFit.contain);
      } else {
        image = Image.asset(path, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Image.asset(fallbackAsset, fit: BoxFit.contain));
      }
    } else {
      image = Image.asset(fallbackAsset, fit: BoxFit.contain);
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Transform.scale(
        scale: scale,
        child: image,
      ),
    );
  }
}

class _CellWidget extends StatelessWidget {
  const _CellWidget(this.text, this.bold, this.align);
  final String text;
  final bool bold;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(text, textAlign: align, style: TextStyle(fontSize: 12.5, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
