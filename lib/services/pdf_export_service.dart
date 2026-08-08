import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/pie_chart_widget.dart';

class PdfExportService {
  static Future<void> exportSalesReport({
    required String period,
    required double totalRevenue,
    required int totalOrders,
    required List<PieChartSegment> segments,
    String merchantName = 'AxisCo Store',
  }) async {
    final pdf = pw.Document();

    final avgOrder = totalOrders > 0 ? (totalRevenue / totalOrders) : 0.0;
    final String dateStr = DateTime.now().toString().split('.')[0];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1E40AF'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          merchantName,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Sales & Analytics Report ($period)',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Generated On:',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          dateStr,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // 2. Summary KPI Cards Grid
              pw.Row(
                children: [
                  _buildKPICard(
                    title: 'Total Sales Revenue',
                    value: '\$${totalRevenue.toStringAsFixed(2)}',
                    colorHex: '#10B981',
                  ),
                  pw.SizedBox(width: 12),
                  _buildKPICard(
                    title: 'Total Orders',
                    value: '$totalOrders',
                    colorHex: '#3B82F6',
                  ),
                  pw.SizedBox(width: 12),
                  _buildKPICard(
                    title: 'Average Order Value',
                    value: '\$${avgOrder.toStringAsFixed(2)}',
                    colorHex: '#8B5CF6',
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // 3. Category Breakdown Table Title
              pw.Text(
                'Category Performance & Sales Proportion',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 12),

              // 4. Sales Table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E2E8F0'),
                  width: 1,
                ),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F5F9'),
                    ),
                    children: [
                      _buildTableCell('Category / Product', isHeader: true),
                      _buildTableCell(
                        'Units Sold',
                        isHeader: true,
                        align: pw.TextAlign.center,
                      ),
                      _buildTableCell(
                        'Proportion (%)',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                  // Rows
                  ...segments.map((seg) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(seg.label),
                        _buildTableCell(
                          seg.amountText,
                          align: pw.TextAlign.center,
                        ),
                        _buildTableCell(
                          seg.percentageText,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),

              // 5. PDF Footer
              pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'AxisCo POS • Executive Sales Summary',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Developed by Phalla David',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Share / Print PDF Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Sales_Report_${period}_$dateStr.pdf',
    );
  }

  static pw.Widget _buildKPICard({
    required String title,
    required String value,
    required String colorHex,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F8FAFC'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex(colorHex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromHex(isHeader ? '#0F172A' : '#334155'),
        ),
      ),
    );
  }
}
