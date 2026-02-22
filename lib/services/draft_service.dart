import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/receipt_data.dart';

class DraftService {
  static const _currentKey = 'nota_alya_current_v1';
  static const _batchKey = 'nota_alya_batch_v1';

  Future<ReceiptData?> loadCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentKey);
    if (raw == null) return null;
    return ReceiptData.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<List<ReceiptData>> loadBatch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_batchKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ReceiptData.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveCurrent(ReceiptData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentKey, jsonEncode(data.toMap()));
  }

  Future<void> saveBatch(List<ReceiptData> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_batchKey, jsonEncode(data.map((e) => e.toMap()).toList()));
  }
}
