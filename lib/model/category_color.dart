import 'package:drift/drift.dart';

// 카테고리 컬러 테이블
class CategoryColors extends Table {
  // Primary Key
  IntColumn get id => integer().autoIncrement()();
  // 색상 코드
  TextColumn get hexCode => text()();
}
