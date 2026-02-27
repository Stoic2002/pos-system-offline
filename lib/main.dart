import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Database
  await DatabaseHelper.instance.database;

  // Initialize Indonesian locale formatting
  await initializeDateFormatting('id_ID', null);

  // Check if first time
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(ProviderScope(child: KasirGoApp(isFirstTime: isFirstTime)));
}
