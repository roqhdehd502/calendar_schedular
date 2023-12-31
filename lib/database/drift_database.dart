import 'dart:io';

import 'package:calendar_schedular/model/schedule_with_color.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:calendar_schedular/model/category_color.dart';
import 'package:calendar_schedular/model/schedule.dart';
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

// When It updated database structure, Follow this command below in terminal
// $ flutter pub run build_runner build

// 지정한 Model 가져오기
@DriftDatabase(tables: [
  Schedules,
  CategoryColors,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // DB 업데이트 버전
  @override
  int get schemaVersion => 1;

  // 일자별 스케쥴(Color 포함) 목록 Select (업데이트 된 값을 불러와야 하므로 Stream, watch 사용)
  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);
    query.where(schedules.date.equals(date));
    query.orderBy([
      OrderingTerm.asc(schedules.startTime),
    ]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
              )
              .toList(),
        );
  }

  // 특정 스케쥴 Select
  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle();

  // 카테고리 컬러 테이블 Select
  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  // 스케쥴 테이블 Insert
  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);
  // 카테고리 컬러 테이블 Insert
  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  // 스케쥴 테이블 Update
  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  // 스케쥴 테이블 Delete
  Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();
}

// DB 연결 설정
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
