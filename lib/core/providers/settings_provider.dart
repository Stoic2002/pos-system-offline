import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, Map<String, String>>(() {
      return SettingsNotifier();
    });

class SettingsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    // Cannot be async build easily if we need sync return initially, so keep state as empty initially
    _loadSettings();
    return {};
  }

  Future<void> _loadSettings() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('settings');
    final Map<String, String> settings = {};
    for (var row in results) {
      settings[row['key'] as String] = row['value'] as String;
    }
    state = settings;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update local state
    state = {...state, key: value};
  }

  String? getSetting(String key) {
    return state[key];
  }
}
