// lib/screens/pdf_preview_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final path = await FilePicker.platform.saveFile(
                fileName: 'recibo.pdf',
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (path != null) {
                await File(path).writeAsBytes(pdfBytes);
              }
            },
          ),
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
