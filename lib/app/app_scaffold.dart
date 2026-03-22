import 'package:flutter/material.dart';

import '../features/comparison/presentation/comparison_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/mosques/presentation/mosques_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  static const _tabs = <_AppTab>[
    _AppTab(label: 'Today', icon: Icons.schedule_rounded, screen: HomeScreen()),
    _AppTab(
      label: 'Mosques',
      icon: Icons.location_city_rounded,
      screen: MosquesScreen(),
    ),
    _AppTab(
      label: 'Compare',
      icon: Icons.table_chart_rounded,
      screen: ComparisonScreen(),
    ),
    _AppTab(
      label: 'Settings',
      icon: Icons.tune_rounded,
      screen: SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];

    return AppScaffoldTabController(
      setCurrentIndex: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Scaffold(
        appBar: AppBar(title: Text(currentTab.label)),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _currentIndex,
            children: _tabs.map((tab) => tab.screen).toList(),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AppScaffoldTabController extends InheritedWidget {
  const AppScaffoldTabController({
    super.key,
    required this.setCurrentIndex,
    required super.child,
  });

  final ValueChanged<int> setCurrentIndex;

  static AppScaffoldTabController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppScaffoldTabController>();
  }

  @override
  bool updateShouldNotify(AppScaffoldTabController oldWidget) => false;
}

class _AppTab {
  const _AppTab({
    required this.label,
    required this.icon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final Widget screen;
}
