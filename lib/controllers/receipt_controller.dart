import 'package:flutter/material.dart';

import '../core/receipt_number_generator.dart';
import '../models/app_settings.dart';
import '../models/receipt_data.dart';
import '../models/receipt_item.dart';
import '../services/draft_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';

class ReceiptController extends ChangeNotifier {
  ReceiptController(this._settingsService, this._pdfService, this._draftService);

  final SettingsService _settingsService;
  final PdfService _pdfService;
  final DraftService _draftService;

  AppSettings settings = AppSettings.initial();
  late ReceiptData current;
  final List<ReceiptData> batchQueue = [];
  int editingBatchIndex = -1;
  bool loading = true;

  Future<void> init() async {
    settings = await _settingsService.load();
    current = _newReceipt();

    final savedCurrent = await _draftService.loadCurrent();
    final savedBatch = await _draftService.loadBatch();
    if (savedCurrent != null) {
      current = savedCurrent;
    }
    batchQueue
      ..clear()
      ..addAll(savedBatch);

    loading = false;
    notifyListeners();
  }

  ReceiptData _newReceipt() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final no = ReceiptNumberGenerator.generate(settings);
    return ReceiptData.createDefault(settings, id, no);
  }

  void setThemeSeed(int color) {
    settings.themeSeed = color;
    _save();
    notifyListeners();
  }

  void addCustomThemeColor(int color) {
    if (!settings.customThemeColors.contains(color)) {
      settings.customThemeColors = [...settings.customThemeColors, color];
    }
    settings.themeSeed = color;
    _save();
    notifyListeners();
  }

  void toggleDarkMode() {
    settings.isDarkMode = !settings.isDarkMode;
    _save();
    notifyListeners();
  }

  void updateCurrent(void Function(ReceiptData data) updater) {
    updater(current);
    _saveDraft();
    notifyListeners();
  }

  void addItem() {
    current.items.add(
      ReceiptItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        quantity: 1,
        name: settings.defaultItemName,
        description: settings.defaultItemDescription,
        price: settings.defaultItemPrice,
      ),
    );
    _saveDraft();
    notifyListeners();
  }

  void removeItem(int index) {
    if (current.items.length <= 1) return;
    current.items.removeAt(index);
    _saveDraft();
    notifyListeners();
  }

  Future<void> addToBatch() async {
    settings.receiptCounter += 1;
    await _save();

    if (editingBatchIndex >= 0) {
      batchQueue[editingBatchIndex] = current.copy();
      editingBatchIndex = -1;
    } else {
      batchQueue.add(current.copy());
    }

    current = _newReceipt();
    await _saveDraft();
    notifyListeners();
  }

  void editBatch(int index) {
    editingBatchIndex = index;
    current = batchQueue[index].copy();
    _saveDraft();
    notifyListeners();
  }

  void deleteBatch(int index) {
    batchQueue.removeAt(index);
    _saveDraft();
    notifyListeners();
  }

  void clearBatch() {
    batchQueue.clear();
    editingBatchIndex = -1;
    _saveDraft();
    notifyListeners();
  }

  Future<void> printCurrent() {
    final (w, h) = _paperSize();
    return _pdfService.printReceipts(
      [current],
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
  }

  Future<void> printBatch() {
    if (batchQueue.isEmpty) return Future.value();
    final (w, h) = _paperSize();
    return _pdfService.printReceipts(
      batchQueue,
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
  }

  void setLogoMainPath(String path) {
    settings.logoMainPath = path;
    current.logoMainPath = path;
    _save();
    _saveDraft();
    notifyListeners();
  }

  void setLogoSignaturePath(String path) {
    settings.logoSignaturePath = path;
    current.logoSignaturePath = path;
    _save();
    _saveDraft();
    notifyListeners();
  }

  void setLogoMainScale(int value) {
    settings.logoMainScale = value;
    current.logoMainScale = value;
    _save();
    _saveDraft();
    notifyListeners();
  }

  void setLogoSignatureScale(int value) {
    settings.logoSignatureScale = value;
    current.logoSignatureScale = value;
    _save();
    _saveDraft();
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await _save();
    await _saveDraft();
    notifyListeners();
  }

  Future<void> saveSettingsAndNewReceipt() async {
    await _save();
    current = _newReceipt();
    await _saveDraft();
    notifyListeners();
  }

  Future<void> resetToEmptyDefaults() async {
    settings = AppSettings.initial();
    current = _newReceipt();
    batchQueue.clear();
    editingBatchIndex = -1;
    await _save();
    await _saveDraft();
    notifyListeners();
  }

  Future<void> savePrintPreferences() async {
    await _save();
    notifyListeners();
  }

  (double, double) _paperSize() {
    switch (settings.paperPreset) {
      case 'A4':
        return (210, 297);
      case 'Letter':
        return (216, 279);
      case 'Thermal 80mm':
        return (80, 300);
      case 'Thermal 58mm':
        return (58, 220);
      case 'Custom':
        return (
          settings.customPaperWidthMm.clamp(40, 320),
          settings.customPaperHeightMm.clamp(80, 480),
        );
      case 'F4':
      default:
        return (210, 330);
    }
  }

  Future<void> _save() => _settingsService.save(settings);

  Future<void> _saveDraft() async {
    await _draftService.saveCurrent(current);
    await _draftService.saveBatch(batchQueue);
  }
}
