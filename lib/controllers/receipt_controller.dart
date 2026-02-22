import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/receipt_number_generator.dart';
import '../models/app_settings.dart';
import '../models/receipt_data.dart';
import '../models/receipt_history_entry.dart';
import '../models/receipt_item.dart';
import '../services/draft_service.dart';
import '../services/history_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';

class ReceiptController extends ChangeNotifier {
  ReceiptController(this._settingsService, this._pdfService, this._draftService, this._historyService);

  final SettingsService _settingsService;
  final PdfService _pdfService;
  final DraftService _draftService;
  final HistoryService _historyService;

  AppSettings settings = AppSettings.initial();
  late ReceiptData current;
  final List<ReceiptData> batchQueue = [];
  final List<ReceiptHistoryEntry> history = [];
  int editingBatchIndex = -1;
  bool loading = true;

  Future<void> init() async {
    settings = await _settingsService.load();
    current = _newReceipt();

    final savedCurrent = await _draftService.loadCurrent();
    final savedBatch = await _draftService.loadBatch();
    final savedHistory = await _historyService.load();
    if (savedCurrent != null) {
      current = savedCurrent;
    }
    batchQueue
      ..clear()
      ..addAll(savedBatch);
    history
      ..clear()
      ..addAll(savedHistory);

    loading = false;
    notifyListeners();
  }

  ReceiptData _newReceipt() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final no = ReceiptNumberGenerator.generate(settings);
    final data = ReceiptData.createDefault(settings, id, no);
    return _emptyEditableFields(data);
  }

  ReceiptData _emptyEditableFields(ReceiptData data) {
    data.recipientName = '';
    data.recipientLine2 = '';
    data.signer = '';
    data.senderDetails = [];
    data.items = [
      ReceiptItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        quantity: 1,
        name: '',
        description: '',
        price: 0,
      ),
    ];
    return data;
  }

  void setThemeSeed(int color) {
    settings.themeSeed = color;
    _save();
    notifyListeners();
  }

  void refreshLayout() {
    current = _newReceipt();
    editingBatchIndex = -1;
    _saveDraft();
    notifyListeners();
  }

  void setReceiptCounter(int value) {
    settings.receiptCounter = value < 1 ? 1 : value;
    current.no = ReceiptNumberGenerator.generate(settings);
    _save();
    _saveDraft();
    notifyListeners();
  }

  void setReceiptPrefix(String value) {
    settings.receiptPrefix = value;
    current.no = ReceiptNumberGenerator.generate(settings);
    _save();
    _saveDraft();
    notifyListeners();
  }

  void setReceiptFormat(String value) {
    settings.receiptFormat = value;
    current.no = ReceiptNumberGenerator.generate(settings);
    _save();
    _saveDraft();
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
    batchQueue.add(current.copy());
    settings.receiptCounter += 1;
    await _save();

    current = _newReceipt();
    editingBatchIndex = -1;
    await _saveDraft();
    notifyListeners();
  }

  void editBatch(int index) {
    editingBatchIndex = index;
    current = batchQueue[index].copy();
    _saveDraft();
    notifyListeners();
  }

  void useBatchAsTemplate(int index) {
    final template = batchQueue[index].copy();
    template.no = ReceiptNumberGenerator.generate(settings);
    template.date = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
    current = template;
    editingBatchIndex = -1;
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

  Future<void> printCurrent() async {
    final (w, h) = _paperSize();
    await _pdfService.printReceipts(
      [current],
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
    await addHistoryFromReceipt(current.copy());
  }

  Future<void> printBatch() async {
    if (batchQueue.isEmpty) return;
    final (w, h) = _paperSize();
    await _pdfService.printReceipts(
      batchQueue,
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
    for (final r in batchQueue) {
      await addHistoryFromReceipt(r.copy());
    }
  }

  Future<String?> saveCurrentToPdf() async {
    final (w, h) = _paperSize();
    final initialDir = await _ensureDefaultPdfDirectory();
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan PDF Kwitansi',
      fileName: 'kwitansi_${current.no.replaceAll('/', '_')}.pdf',
      initialDirectory: initialDir,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path == null) return null;

    final bytes = await _pdfService.buildPdfBytes(
      [current],
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
    await File(path).writeAsBytes(bytes, flush: true);
    await addHistoryFromReceipt(current.copy());
    return path;
  }

  Future<String?> saveBatchToPdf() async {
    if (batchQueue.isEmpty) return null;
    final (w, h) = _paperSize();
    final initialDir = await _ensureDefaultPdfDirectory();
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan PDF Semua Batch',
      fileName: 'kwitansi_batch_${DateTime.now().millisecondsSinceEpoch}.pdf',
      initialDirectory: initialDir,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path == null) return null;

    final bytes = await _pdfService.buildPdfBytes(
      batchQueue,
      printScale: settings.printScale,
      paperWidthMm: w,
      paperHeightMm: h,
    );
    await File(path).writeAsBytes(bytes, flush: true);
    for (final r in batchQueue) {
      await addHistoryFromReceipt(r.copy());
    }
    return path;
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

  void setCapSignaturePath(String path) {
    settings.capSignaturePath = path;
    current.capSignaturePath = path;
    _save();
    _saveDraft();
    notifyListeners();
  }

  void toggleCapSignature(bool enabled) {
    settings.capSignatureEnabled = enabled;
    current.capSignatureEnabled = enabled;
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
    history.clear();
    editingBatchIndex = -1;
    await _save();
    await _saveDraft();
    await _historyService.save(history);
    notifyListeners();
  }

  Future<void> savePrintPreferences() async {
    await _save();
    notifyListeners();
  }

  Future<void> addHistoryFromReceipt(ReceiptData receipt) async {
    history.insert(
      0,
      ReceiptHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        title: receipt.no.isEmpty ? 'Kwitansi' : receipt.no,
        receipt: receipt,
      ),
    );
    await _historyService.save(history);
    notifyListeners();
  }

  void loadHistoryToCurrent(ReceiptHistoryEntry entry) {
    current = entry.receipt.copy();
    notifyListeners();
  }

  Future<void> updateHistoryFromCurrent(String id) async {
    final idx = history.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    history[idx] = ReceiptHistoryEntry(
      id: id,
      createdAt: history[idx].createdAt,
      title: current.no.isEmpty ? history[idx].title : current.no,
      receipt: current.copy(),
    );
    await _historyService.save(history);
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    history.removeWhere((e) => e.id == id);
    await _historyService.save(history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _historyService.save(history);
    notifyListeners();
  }

  Future<String> _ensureDefaultPdfDirectory() async {
    String root;
    if (Platform.isWindows) {
      root = Platform.environment['USERPROFILE'] ?? Directory.current.path;
    } else {
      root = Platform.environment['HOME'] ?? Directory.current.path;
    }
    final dir = Directory('$root${Platform.pathSeparator}Documents${Platform.pathSeparator}AlyaaFlorist${Platform.pathSeparator}PDF');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
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
