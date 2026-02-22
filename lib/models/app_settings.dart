class AppSettings {
  AppSettings({
    required this.themeSeed,
    required this.isDarkMode,
    required this.printScale,
    required this.receiptCounter,
    required this.receiptPrefix,
    required this.receiptFormat,
    required this.defaultRecipientName,
    required this.defaultRecipientLine2,
    required this.defaultItemName,
    required this.defaultItemDescription,
    required this.defaultItemPrice,
    required this.defaultSigner,
    required this.defaultSenderDetails,
    required this.customThemeColors,
    required this.companyName,
    required this.subName,
    required this.slogan,
    required this.addressLines,
    required this.printConnection,
    required this.paperPreset,
    required this.customPaperWidthMm,
    required this.customPaperHeightMm,
    this.logoMainPath,
    this.logoSignaturePath,
    this.capSignaturePath,
    this.capSignatureEnabled = true,
    this.logoMainScale = 50,
    this.logoSignatureScale = 85,
  });

  int themeSeed;
  bool isDarkMode;
  int printScale;
  int receiptCounter;
  String receiptPrefix;
  String receiptFormat;
  String defaultRecipientName;
  String defaultRecipientLine2;
  String defaultItemName;
  String defaultItemDescription;
  int defaultItemPrice;
  String defaultSigner;
  List<String> defaultSenderDetails;
  List<int> customThemeColors;
  String companyName;
  String subName;
  String slogan;
  List<String> addressLines;
  String printConnection;
  String paperPreset;
  double customPaperWidthMm;
  double customPaperHeightMm;
  String? logoMainPath;
  String? logoSignaturePath;
  String? capSignaturePath;
  bool capSignatureEnabled;
  int logoMainScale;
  int logoSignatureScale;

  factory AppSettings.initial() => AppSettings(
        themeSeed: 0xFF3F51B5,
        isDarkMode: false,
        printScale: 100,
        receiptCounter: 1,
        receiptPrefix: 'AF',
        receiptFormat: '{counter}/{prefix}/{month}/{year}',
        defaultRecipientName: '',
        defaultRecipientLine2: '',
        defaultItemName: '',
        defaultItemDescription: '',
        defaultItemPrice: 0,
        defaultSigner: '',
        defaultSenderDetails: const [],
        customThemeColors: const [],
        companyName: 'ALYAA Florist',
        subName: '( UD. ALYAA )',
        slogan: 'Pusat Karangan Bunga, Dekorasi, Mobil Hias',
        addressLines: const [
          'Jl Kartini No. 01 Rembang (Komplek KODIM / Depan RM Warung Ndeso)',
          'Jl. Pierre Tendean No. 03 / Jl. Cinta Rembang',
          'HP: 0813 2570 5543 / 0812 2552 4905',
        ],
        printConnection: 'Sistem (USB/IPP/Bluetooth)',
        paperPreset: 'F4',
        customPaperWidthMm: 210,
        customPaperHeightMm: 330,
        logoMainPath: 'assets/LogoMain.jpg',
        logoSignaturePath: 'assets/deafult_ttd.png',
        capSignaturePath: 'assets/cap_ttd.png',
        capSignatureEnabled: true,
      );
}
