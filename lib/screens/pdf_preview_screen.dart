// lib/screens/pdf_preview_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const PdfPreviewScreen({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualização do Recibo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await Printing.layoutPdf(onLayout: (format) => pdfBytes);
            },
          ),
        ],
      ),
      body: PdfPreview(build: (format) => pdfBytes),
    );
  }
}
