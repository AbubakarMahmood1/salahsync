import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/app_theme_mode.dart';
import 'app_scaffold.dart';
import 'providers.dart';
import 'theme.dart';

class SalahSyncApp extends ConsumerStatefulWidget {
  const SalahSyncApp({super.key});

  @override
  ConsumerState<SalahSyncApp> createState() => _SalahSyncAppState();
}

class _SalahSyncAppState extends ConsumerState<SalahSyncApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncNotificationsAfterForegroundChange(ref));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appBootstrapProvider);
    final themeModeAsync = ref.watch(appThemeModeProvider);
    ref.watch(notificationSyncTriggerProvider);

    return MaterialApp(
      title: 'SalahSync',
      debugShowCheckedModeBanner: false,
      theme: buildSalahSyncTheme(brightness: Brightness.light),
      darkTheme: buildSalahSyncTheme(brightness: Brightness.dark),
      themeMode: themeModeAsync.when(
        data: _materialThemeModeFor,
        loading: () => ThemeMode.system,
        error: (_, _) => ThemeMode.system,
      ),
      home: const AppScaffold(),
    );
  }
}

ThemeMode _materialThemeModeFor(AppThemeMode value) {
  return switch (value) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
