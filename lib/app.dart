import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/home_shell.dart';
import 'utils/app_theme.dart';

class DompetKuApp extends StatelessWidget {
  const DompetKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;
    return MaterialApp(
      title: 'DompetKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomeShell(),
    );
  }
}