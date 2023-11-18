import 'package:calendar_schedular/database/drift_database.dart';
import 'package:calendar_schedular/screen/home_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'const/colors.dart';

void main() async {
  // 위젯 실행전 초기화 여부 함수
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

  final colors = await database.getCategoryColors();

  if (colors.isEmpty) {
    for (String hexCode in DEFAULT_COLORS) {
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode),
        ),
      );
    }
  }

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: const HomeScreen(),
    ),
  );
}
