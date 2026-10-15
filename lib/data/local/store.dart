import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight JSON persistence for the whole demo state.
/// Key: single blob so role-switching shares one source of truth.
class LocalStore {
  static const key = 'kaamsetu_v1';
  Future<Map<String, dynamic>?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> json) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, jsonEncode(json));
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(key);
  }
}
