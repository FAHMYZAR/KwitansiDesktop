import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const _key = 'nota_alya_settings_v1';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return AppSettings.initial();

    final map = jsonDecode(raw) as Map<String, dynamic>;

    const defaultMain = 'assets/LogoMain.jpg';
    const defaultPenTtd = 'assets/deafult_ttd.png';
    const defaultCap = 'assets/cap_ttd.png';

    String? mainPath = map['logoMainPath'] as String?;
    String? penPath = map['logoSignaturePath'] as String?;
    String? capPath = map['capSignaturePath'] as String?;

    // Migrasi data lama agar layer default TTD (pena) & cap tidak kebalik.
    if (penPath == null || penPath.isEmpty || penPath.endsWith('/logo_ttd.png') || penPath.endsWith('/logo_ttd.png')) {
      penPath = defaultPenTtd;
    }
    if (capPath == null || capPath.isEmpty) {
      capPath = defaultCap;
    }
    if (mainPath == null || mainPath.isEmpty || mainPath.endsWith('/logo_main.png')) {
      mainPath = defaultMain;
    }
    if (mainPath.contains('/assets/')) mainPath = defaultMain;
    if (penPath.contains('/assets/')) penPath = defaultPenTtd;
    if (capPath.contains('/assets/')) capPath = defaultCap;

    return AppSettings(
      themeSeed: map['themeSeed'] as int? ?? 0xFF3F51B5,
      isDarkMode: map['isDarkMode'] as bool? ?? false,
      printScale: map['printScale'] as int? ?? 100,
      receiptCounter: ((map['receiptCounter'] as int?) ?? 1) < 1 ? 1 : ((map['receiptCounter'] as int?) ?? 1),
      receiptPrefix: map['receiptPrefix'] as String? ?? 'AF',
      receiptFormat: map['receiptFormat'] as String? ?? '{counter}/{prefix}/{month}/{year}',
      defaultRecipientName: map['defaultRecipientName'] as String? ?? '',
      defaultRecipientLine2: map['defaultRecipientLine2'] as String? ?? '',
      defaultItemName: map['defaultItemName'] as String? ?? '',
      defaultItemDescription: map['defaultItemDescription'] as String? ?? '',
      defaultItemPrice: map['defaultItemPrice'] as int? ?? 0,
      defaultSigner: map['defaultSigner'] as String? ?? '',
      defaultSenderDetails: ((map['defaultSenderDetails'] as List?) ?? const []).map((e) => '$e').toList(),
      customThemeColors: ((map['customThemeColors'] as List?) ?? const []).map((e) => e as int).toList(),
      companyName: map['companyName'] as String? ?? 'ALYAA Florist',
      subName: map['subName'] as String? ?? '( UD. ALYAA )',
      slogan: map['slogan'] as String? ?? 'Pusat Karangan Bunga, Dekorasi, Mobil Hias',
      addressLines: ((map['addressLines'] as List?) ?? const [
        'Jl Kartini No. 01 Rembang (Komplek KODIM / Depan RM Warung Ndeso)',
        'Jl. Pierre Tendean No. 03 / Jl. Cinta Rembang',
        'HP: 0813 2570 5543 / 0812 2552 4905',
      ]).map((e) => '$e').toList(),
      printConnection: map['printConnection'] as String? ?? 'Sistem (USB/IPP/Bluetooth)',
      paperPreset: map['paperPreset'] as String? ?? 'F4',
      customPaperWidthMm: (map['customPaperWidthMm'] as num?)?.toDouble() ?? 210,
      customPaperHeightMm: (map['customPaperHeightMm'] as num?)?.toDouble() ?? 330,
      logoMainPath: mainPath,
      logoSignaturePath: penPath,
      capSignaturePath: capPath,
      capSignatureEnabled: map['capSignatureEnabled'] as bool? ?? true,
      logoMainScale: map['logoMainScale'] as int? ?? 50,
      logoSignatureScale: map['logoSignatureScale'] as int? ?? 85,
    );
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'themeSeed': s.themeSeed,
      'isDarkMode': s.isDarkMode,
      'printScale': s.printScale,
      'receiptCounter': s.receiptCounter,
      'receiptPrefix': s.receiptPrefix,
      'receiptFormat': s.receiptFormat,
      'defaultRecipientName': s.defaultRecipientName,
      'defaultRecipientLine2': s.defaultRecipientLine2,
      'defaultItemName': s.defaultItemName,
      'defaultItemDescription': s.defaultItemDescription,
      'defaultItemPrice': s.defaultItemPrice,
      'defaultSigner': s.defaultSigner,
      'defaultSenderDetails': s.defaultSenderDetails,
      'customThemeColors': s.customThemeColors,
      'companyName': s.companyName,
      'subName': s.subName,
      'slogan': s.slogan,
      'addressLines': s.addressLines,
      'printConnection': s.printConnection,
      'paperPreset': s.paperPreset,
      'customPaperWidthMm': s.customPaperWidthMm,
      'customPaperHeightMm': s.customPaperHeightMm,
      'logoMainPath': s.logoMainPath,
      'logoSignaturePath': s.logoSignaturePath,
      'capSignaturePath': s.capSignaturePath,
      'capSignatureEnabled': s.capSignatureEnabled,
      'logoMainScale': s.logoMainScale,
      'logoSignatureScale': s.logoSignatureScale,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
