import 'package:flutter/material.dart';
import 'package:filely/file_explorer.dart';
import 'theme/app_theme.dart';

class FilelyApp extends StatelessWidget {
  const FilelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppTheme.themeMode,
      home: const SafeArea(child: FileExplorer()),
    );
  }
}
