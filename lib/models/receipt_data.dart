import 'package:intl/intl.dart';

import 'app_settings.dart';
import 'receipt_item.dart';

class ReceiptData {
  ReceiptData({
    required this.id,
    required this.no,
    required this.date,
    required this.recipientName,
    required this.recipientLine2,
    required this.items,
    required this.signer,
    required this.senderDetails,
    required this.companyName,
    required this.subName,
    required this.slogan,
    required this.addressLines,
    this.logoMainPath,
    this.logoSignaturePath,
    this.logoMainScale = 100,
    this.logoSignatureScale = 100,
  });

  final String id;
  String no;
  String date;
  String recipientName;
  String recipientLine2;
  List<ReceiptItem> items;
  String signer;
  List<String> senderDetails;
  String companyName;
  String subName;
  String slogan;
  List<String> addressLines;
  String? logoMainPath;
  String? logoSignaturePath;
  int logoMainScale;
  int logoSignatureScale;

  int get grandTotal => items.fold(0, (sum, item) => sum + item.total);

  ReceiptData copy() => ReceiptData(
        id: id,
        no: no,
        date: date,
        recipientName: recipientName,
        recipientLine2: recipientLine2,
        items: items.map((e) => e.copy()).toList(),
        signer: signer,
        senderDetails: [...senderDetails],
        companyName: companyName,
        subName: subName,
        slogan: slogan,
        addressLines: [...addressLines],
        logoMainPath: logoMainPath,
        logoSignaturePath: logoSignaturePath,
        logoMainScale: logoMainScale,
        logoSignatureScale: logoSignatureScale,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'no': no,
        'date': date,
        'recipientName': recipientName,
        'recipientLine2': recipientLine2,
        'items': items.map((e) => e.toMap()).toList(),
        'signer': signer,
        'senderDetails': senderDetails,
        'companyName': companyName,
        'subName': subName,
        'slogan': slogan,
        'addressLines': addressLines,
        'logoMainPath': logoMainPath,
        'logoSignaturePath': logoSignaturePath,
        'logoMainScale': logoMainScale,
        'logoSignatureScale': logoSignatureScale,
      };

  factory ReceiptData.fromMap(Map<String, dynamic> map) => ReceiptData(
        id: map['id'] as String,
        no: map['no'] as String? ?? '',
        date: map['date'] as String? ?? '',
        recipientName: map['recipientName'] as String? ?? '',
        recipientLine2: map['recipientLine2'] as String? ?? '',
        items: ((map['items'] as List?) ?? const [])
            .map((e) => ReceiptItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        signer: map['signer'] as String? ?? '',
        senderDetails: ((map['senderDetails'] as List?) ?? const []).map((e) => '$e').toList(),
        companyName: map['companyName'] as String? ?? 'ALYAA Florist',
        subName: map['subName'] as String? ?? '( UD. ALYAA )',
        slogan: map['slogan'] as String? ?? 'Pusat Karangan Bunga, Dekorasi, Mobil Hias',
        addressLines: ((map['addressLines'] as List?) ?? const []).map((e) => '$e').toList(),
        logoMainPath: map['logoMainPath'] as String?,
        logoSignaturePath: map['logoSignaturePath'] as String?,
        logoMainScale: map['logoMainScale'] as int? ?? 100,
        logoSignatureScale: map['logoSignatureScale'] as int? ?? 100,
      );

  static ReceiptData createDefault(AppSettings settings, String id, String no) {
    return ReceiptData(
      id: id,
      no: no,
      date: DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now()),
      recipientName: settings.defaultRecipientName,
      recipientLine2: settings.defaultRecipientLine2,
      items: [
        ReceiptItem(
          id: 'item_0',
          quantity: 1,
          name: settings.defaultItemName,
          description: settings.defaultItemDescription,
          price: settings.defaultItemPrice,
        ),
      ],
      signer: settings.defaultSigner,
      senderDetails: [...settings.defaultSenderDetails],
      companyName: settings.companyName,
      subName: settings.subName,
      slogan: settings.slogan,
      addressLines: [...settings.addressLines],
      logoMainPath: settings.logoMainPath,
      logoSignaturePath: settings.logoSignaturePath,
      logoMainScale: settings.logoMainScale,
      logoSignatureScale: settings.logoSignatureScale,
    );
  }
}
