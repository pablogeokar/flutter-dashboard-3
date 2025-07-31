import 'dart:io';
import 'package:flutter_dashboard_3/utils/currency_format.dart';
import 'package:flutter_dashboard_3/utils/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:flutter_dashboard_3/models/contribuicao.dart';

class PdfService {
  static Future<File> generateContributionReceipt(
    Contribuicao contribuicao,
  ) async {
    final pdf = pw.Document();

    // Carrega a logo
    final logo = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho com logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 100, height: 100),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'RECIBO DE PAGAMENTO',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Nº ${contribuicao.id}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Data: ${_formatDate(contribuicao.dataPagamento ?? DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Informações do recibo
              pw.Text('Recebi de:', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                contribuicao.membroNome ?? '',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text('A importância de:', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                '${currencyFormat.format(contribuicao.valor)} (${numberToWords(contribuicao.valor)})',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text('Referente a:', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                'Contribuição mensal - ${contribuicao.mesReferenciaNome}/${contribuicao.anoReferencia}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 20),

              if (contribuicao.observacoes != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Observações:', style: pw.TextStyle(fontSize: 14)),
                    pw.Text(
                      contribuicao.observacoes!,
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),

              // Assinatura
              pw.SizedBox(height: 60),
              pw.Divider(thickness: 1),
              pw.Center(
                child: pw.Text('Assinatura', style: pw.TextStyle(fontSize: 14)),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '___________________________',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Responsável',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Salva o PDF temporariamente
    // método antigo usando path_provider
    // final output = await getTemporaryDirectory();
    // final file = File('${output.path}/recibo_${contribuicao.id}.pdf');
    // await file.writeAsBytes(await pdf.save());

    // return file;

    // Salva o PDF temporariamente
    final outputDir =
        Directory.systemTemp; // Usa o diretório temporário do sistema
    final filePath = p.join(outputDir.path, 'recibo_${contribuicao.id}.pdf');
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> printReceipt(Contribuicao contribuicao) async {
    final pdf = await generateContributionReceipt(contribuicao);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.readAsBytes(),
    );
  }

  static Future<void> shareReceipt(Contribuicao contribuicao) async {
    final pdf = await generateContributionReceipt(contribuicao);
    await Printing.sharePdf(
      bytes: await pdf.readAsBytes(),
      filename: 'recibo_${contribuicao.id}.pdf',
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
