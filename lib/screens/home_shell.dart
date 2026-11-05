import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'expense_form_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Pengaturan'),
        ],
      ),
    );
  }
}