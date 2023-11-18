import 'package:drift/drift.dart';

// 스케쥴 테이블
class Schedules extends Table {
  // Primary Key
  IntColumn get id => integer().autoIncrement()();
  // 내용
  TextColumn get content => text()();
  // 일정날짜
  DateTimeColumn get date => dateTime()();
  // 시작시간
  IntColumn get startTime => integer()();
  // 종료시간
  IntColumn get endTime => integer()();
  // Foreign Key
  IntColumn get colorId => integer()();
  // 생성날짜
  DateTimeColumn get createdAt => dateTime().clientDefault(
        () => DateTime.now(),
      )();
}
