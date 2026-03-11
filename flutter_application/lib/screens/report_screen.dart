import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Import Model
import 'package:example/models/labSample.dart';

class ReportScreen extends StatelessWidget {
  final dynamic sampleData;
  final LabSample? labData;

  const ReportScreen({
    super.key,
    required this.sampleData,
    this.labData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Preview"),
        backgroundColor: const Color(0xFF006A4E),
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        pdfFileName: "Report_${sampleData.sampName ?? 'DOC'}.pdf",
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();

    // ==========================================================
    // 1. โหลดฟอนต์ภาษาไทยจาก Google Fonts (ต้องต่อเน็ตตอนรันครั้งแรก)
    // ==========================================================
    final ttf = await PdfGoogleFonts.sarabunRegular();
    final ttfBold = await PdfGoogleFonts.sarabunBold();

    // กำหนด Style
    final styleNormal = pw.TextStyle(font: ttf, fontSize: 10);
    final styleBold = pw.TextStyle(
        font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold);
    final styleHeader = pw.TextStyle(
        font: ttfBold, fontSize: 18, fontWeight: pw.FontWeight.bold);
    final styleSection = pw.TextStyle(
        font: ttfBold, fontSize: 12, decoration: pw.TextDecoration.underline);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("MCCC LABORATORY",
                          style:
                              styleHeader.copyWith(color: PdfColors.green900)),
                      pw.Text("Agricultural Science Center",
                          style: styleNormal),
                      pw.Text("Kamphaeng Saen, Nakhon Pathom",
                          style: styleNormal),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("LABORATORY REPORT", style: styleHeader),
                      pw.Text(
                          "Date: ${DateTime.now().toString().substring(0, 10)}",
                          style: styleNormal),
                      pw.Text("Ref ID: ${sampleData.sampName}",
                          style: styleNormal),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2, color: PdfColors.green900),
              pw.SizedBox(height: 20),

              // ---------------- 1. SAMPLE INFO ----------------
              pw.Text("1. SAMPLE INFORMATION", style: styleSection),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // คอลัมน์ซ้าย
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Sample Name", sampleData.sampName,
                              styleBold, styleNormal),
                          _buildInfoRow("Title", sampleData.sampTitle,
                              styleBold, styleNormal),
                          _buildInfoRow("Organism", sampleData.organism,
                              styleBold, styleNormal),
                          _buildInfoRow(
                              "Collected By",
                              sampleData.collectedByName,
                              styleBold,
                              styleNormal),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // คอลัมน์ขวา
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              "Collection Date",
                              sampleData.collectionDate
                                  ?.toString()
                                  .split(' ')[0],
                              styleBold,
                              styleNormal),
                          _buildInfoRow(
                              "Location",
                              "${sampleData.addressSubdistrict ?? '-'} ${sampleData.addressDistrict ?? '-'}",
                              styleBold,
                              styleNormal),
                          _buildInfoRow(
                              "Coordinate",
                              "${sampleData.geoLatlon?[0] ?? '-'}, ${sampleData.geoLatlon?[1] ?? '-'}",
                              styleBold,
                              styleNormal),
                          _buildInfoRow("Method", sampleData.collectMeth,
                              styleBold, styleNormal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ---------------- 2. LAB RESULTS ----------------
              pw.Text("2. LABORATORY RESULTS", style: styleSection),
              pw.SizedBox(height: 5),

              if (labData != null)
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  headerStyle: styleBold.copyWith(color: PdfColors.white),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.green800),
                  cellStyle: styleNormal,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerLeft,
                  },
                  headerHeight: 25,
                  cellHeight: 25, // ลดความสูงบรรทัดให้กระชับ
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2), // Parameter
                    1: const pw.FlexColumnWidth(1), // Result
                    2: const pw.FlexColumnWidth(1), // Unit
                  },
                  headers: ['Parameter / Item', 'Result', 'Unit'],
                  data: [
                    // ====================================================
                    // ตรงนี้คือการดึงค่าจาก LabSample มาโชว์ทีละบรรทัด
                    // (ต้องแก้ให้ตรงกับ field จริงๆ ในไฟล์ labSample.dart ของคุณ)
                    // ====================================================
                    //['Lab ID', labData!.labId?.toString() ?? "-", '-'], // ถ้ามี field labId
                    ['pH Level', labData!.pH?.toString() ?? "-", 'pH'],
                    [
                      'Organic Carbon',
                      labData!.organicCarbon?.toString() ?? "-",
                      '%'
                    ],
                    [
                      'Nitrogen (N)',
                      labData!.nitrogen?.toString() ?? "-",
                      'mg/kg'
                    ],
                    [
                      'Phosphorus (P)',
                      labData!.phosphorus?.toString() ?? "-",
                      'mg/kg'
                    ],
                    [
                      'Potassium (K)',
                      labData!.potassium?.toString() ?? "-",
                      'mg/kg'
                    ],
                    ['Texture', labData!.texture ?? "-", '-'],
                  ],
                )
              else
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Center(
                    child: pw.Text("- No Laboratory Data Recorded -",
                        style: styleNormal),
                  ),
                ),

              pw.SizedBox(height: 10),
              pw.Text("* Note: The results relate only to the items tested.",
                  style: styleNormal.copyWith(
                      fontSize: 8, color: PdfColors.grey700)),

              pw.Spacer(),

              // ---------------- FOOTER & SIGNATURE ----------------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                          width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text("Analyzed By", style: styleBold),
                      pw.Text("( Staff Name )", style: styleNormal),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                          width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text("Approved By", style: styleBold),
                      pw.Text("( Lab Manager )", style: styleNormal),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // Helper Row
  pw.Widget _buildInfoRow(String label, String? value, pw.TextStyle labelStyle,
      pw.TextStyle valueStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text("$label:", style: labelStyle),
          ),
          pw.Expanded(
            child: pw.Text(value ?? "-", style: valueStyle),
          ),
        ],
      ),
    );
  }
}
