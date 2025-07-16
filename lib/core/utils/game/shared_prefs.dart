import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<dynamic> get(String key) async {
    return _prefs.get(key);
  }

  // In shared_prefs.dart
Future<void> save(String key, dynamic value) async {
  if (value is String) {
    await _prefs.setString(key, value);
  } else if (value is int) {
    await _prefs.setInt(key, value);
  } else if (value is bool) {
    await _prefs.setBool(key, value);
  } else if (value is double) {
    await _prefs.setDouble(key, value);
  } else if (value is List<String>) {
    await _prefs.setStringList(key, value);
  } else if (value is List) {
    // Handle list of objects by converting to JSON string
    await _prefs.setString(key, jsonEncode(value));
  } else if (value is Map) {
    // Handle objects by converting to JSON string
    await _prefs.setString(key, jsonEncode(value));
  }
}

  Future<Map<String, dynamic>> getUser() async {
    return {
      'id': _prefs.getString('user_id') ?? 'guest',
      'name': _prefs.getString('user_name') ?? 'Guest',
    };
  }

  Future<void> saveUser(String id, String name) async {
    await _prefs.setString('user_id', id);
    await _prefs.setString('user_name', name);
  }
}