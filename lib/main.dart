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
      title: 'Meu App com Tema',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      //themeMode: ThemeMode.system,
      themeMode: ThemeMode.light, // Forçar tema claro
      home: const MainLayout(),
    );
  }
}
