import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/ibadah/ibadah_task_prayer_link.dart';
import 'package:salahsync/core/ibadah/ibadah_task_repeat_type.dart';
import 'package:salahsync/core/ibadah/ibadah_task_timing.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/ibadah_task_draft.dart';
import 'package:salahsync/data/repositories/ibadah_task_repository.dart';

void main() {
  late AppDatabase database;
  late IbadahTaskRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = IbadahTaskRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('save round-trips repeat metadata and count target', () async {
    final id = await repository.save(
      const IbadahTaskDraft(
        title: 'Morning adhkar',
        description: 'After Fajr',
        prayerLink: IbadahTaskPrayerLink.fajr,
        timing: IbadahTaskTiming.after,
        repeatType: IbadahTaskRepeatType.specificDays,
        repeatDays: {DateTime.monday, DateTime.friday},
        countTarget: 33,
        sortOrder: 2,
      ),
    );

    final saved = await repository.getById(id);
    expect(saved, isNotNull);
    expect(saved!.prayerLink, IbadahTaskPrayerLink.fajr);
    expect(saved.repeatType, IbadahTaskRepeatType.specificDays);
    expect(saved.repeatDays, {DateTime.monday, DateTime.friday});
    expect(saved.countTarget, 33);
    expect(saved.sortOrder, 2);
  });

  test('weekly task requires exactly one weekday', () async {
    await expectLater(
      () => repository.save(
        const IbadahTaskDraft(
          title: 'Weekly halaqa',
          prayerLink: IbadahTaskPrayerLink.none,
          timing: IbadahTaskTiming.after,
          repeatType: IbadahTaskRepeatType.weekly,
          repeatDays: {DateTime.monday, DateTime.friday},
        ),
      ),
      throwsA(isA<IbadahTaskValidationException>()),
    );
  });
}
