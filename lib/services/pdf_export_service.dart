import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helper.dart';

class PdfExportService {
  PdfExportService._();

  static Future<Uint8List> build({
    required List<Expense> expenses,
    required String periodLabel,
  }) async {
    final doc = pw.Document(title: 'Laporan Pengeluaran DompetKu');

    var total = 0;
    final byCategory = <ExpenseCategory, int>{};
    for (final e in expenses) {
      total += e.amount;
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final categories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pw.Widget cell(String text,
        {bool bold = false,
        bool right = false,
        PdfColor color = PdfColors.black}) {
      final t = pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      );
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: right
            ? pw.Align(alignment: pw.Alignment.centerRight, child: t)
            : t,
      );
    }

    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: PdfColors.green700),
        children: [
          cell('Tanggal', bold: true, color: PdfColors.white),
          cell('Nama', bold: true, color: PdfColors.white),
          cell('Kategori', bold: true, color: PdfColors.white),
          cell('Nominal', bold: true, right: true, color: PdfColors.white),
        ],
      ),
      for (final e in expenses)
        pw.TableRow(children: [
          cell(DateHelper.formatDisplay(e.date)),
          cell(e.title),
          cell(e.category.label),
          cell(CurrencyFormatter.format(e.amount), right: true),
        ]),
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (ctx) => [
          pw.Text('Laporan Pengeluaran DompetKu',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Periode: $periodLabel'),
          pw.Text(
              'Dibuat: ${DateHelper.formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total pengeluaran (${expenses.length} transaksi)'),
                pw.Text(CurrencyFormatter.format(total),
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          if (categories.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text('Ringkasan per kategori',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            for (final c in categories)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(c.key.label,
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(CurrencyFormatter.format(c.value),
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
          ],
          pw.SizedBox(height: 16),
          pw.Text('Daftar transaksi',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
            columnWidths: const {
              0: pw.FixedColumnWidth(78),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
              3: pw.FixedColumnWidth(90),
            },
            children: rows,
          ),
        ],
      ),
    );

    return doc.save();
  }
}