import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/app/providers.dart';
import 'package:salahsync/app/salah_sync_app.dart';
import 'package:salahsync/core/settings/app_theme_mode.dart';
import 'package:salahsync/data/db/app_database.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  testWidgets('app shell shows the milestone tabs', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          appThemeModeProvider.overrideWith((ref) {
            return Stream.value(AppThemeMode.system);
          }),
        ],
        child: const SalahSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Mosques'), findsOneWidget);
    expect(find.text('Compare'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Masjid Al-Noor'), findsOneWidget);

    await tester.tap(find.text('Mosques'));
    await tester.pumpAndSettle();
    expect(find.text('Mosque records'), findsOneWidget);

    await tester.tap(find.text('Compare'));
    await tester.pumpAndSettle();
    expect(find.text('Jamaat comparison'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Calculation profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('saved theme mode is applied to MaterialApp', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          appThemeModeProvider.overrideWith((ref) {
            return Stream.value(AppThemeMode.dark);
          }),
        ],
        child: const SalahSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
