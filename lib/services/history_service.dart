import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/receipt_history_entry.dart';

class HistoryService {
  static const _key = 'nota_alya_history_v1';

  Future<List<ReceiptHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ReceiptHistoryEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> save(List<ReceiptHistoryEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toMap()).toList()));
  }
}
