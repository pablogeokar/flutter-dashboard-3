import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/widgets/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compasso Fiscal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const MainLayout(),
    );
  }
}
