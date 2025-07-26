import 'package:flutter/material.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Tela em branco',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
