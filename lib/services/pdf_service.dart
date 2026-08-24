import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../utils/number_to_words.dart';

class PdfService {
  static int _receiptCounter = 1;

  // Foundation details - Update these with your actual details
  static const String registrationNumber = '[Your Registration Number]';
  static const String panNumber = '[Your PAN Number]';
  static const String officeAddress = '[Your Office Address]';
  static const String foundationYear = '2020'; // Update with your foundation year
  static const String mobileNumber = '[Your Mobile Number]';
  static const String emailAddress = '[Your Email]';
  static const String website = '[Your Website]';

  static String generateReceiptNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final counter = _receiptCounter.toString().padLeft(4, '0');
    _receiptCounter++;
    return 'VKF$year$month$day$counter';
  }

  static Future<File> generatePdf(DonationModel donation) async {
    final pdf = pw.Document();
    final receiptNumber = generateReceiptNumber();
    final dateStr = '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}';
    final amountInWords = NumberToWords.convert(donation.amount);

    // Format amount with comma and remove decimal
    final formattedAmount = donation.amount.toInt();
    final amountStr = formattedAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Try to load logo
    pw.ImageProvider? logoImage;
    try {
      try {
        final logoData = await rootBundle.load('assets/logo/logo.png');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (_) {
        final logoData = await rootBundle.load('assets/logo/logo.jpeg');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Logo not found, using text instead');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(45),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.black,
                    width: 1.5,
                  ),
                ),
                padding: const pw.EdgeInsets.all(1),
                child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
              // Header Section - Logo and Organization Name
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo
                    if (logoImage != null)
                      pw.Container(
                        width: 100,
                        height: 100,
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      )
                    else
                      pw.Container(
                        width: 100,
                        height: 100,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF4CAF50),
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'VKF',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    pw.SizedBox(width: 20),
                    // Organization Details - Centered
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          // Organization name with two colors
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: 'VIDHYAKAANTHI ',
                                  style: pw.TextStyle(
                                    fontSize: 22,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(0xFF1F2C58),
                                    font: pw.Font.helveticaBold(),
                                  ),
                                ),
                                pw.TextSpan(
                                  text: 'FOUNDATION',
                                  style: pw.TextStyle(
                                    fontSize: 22,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(0xFF1F2C58),
                                    font: pw.Font.helveticaBold(),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Registration No.: $registrationNumber, PAN NO.: $panNumber',
                            style: pw.TextStyle(
                              fontSize: 9,
                              font: pw.Font.helveticaBold(),
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Off. Add: $officeAddress',
                            style: pw.TextStyle(
                              fontSize: 9,
                              font: pw.Font.helveticaBold(),
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Center(
                  child: pw.Text(
                    'Donation Receipt',
                    style: pw.TextStyle(
                      fontSize: 22,
                      font: pw.Font.helveticaBold(), // ✅ Built-in bold font for thick appearance
                      color: PdfColor.fromInt(0xFF1F2C58), // Dark blue color
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 15),
              // Combined Section - Single Blue Box (extends to edges)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0x80B3C1D9), // Light green background
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(0)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Receipt Number and Date
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: 'Receipt No: ',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  font: pw.Font.times(), // Regular label (not bold)
                                ),
                              ),
                              pw.TextSpan(
                                text: receiptNumber,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  font: pw.Font.helveticaBold(),
                                  color: PdfColor.fromInt(0xFF1F2C58),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: 'Date: ',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  font: pw.Font.times(), // Regular label (not bold)
                                ),
                              ),
                              pw.TextSpan(
                                text: dateStr,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  font: pw.Font.helveticaBold(), color: PdfColor.fromInt(0xFF1F2C58), // Bold value
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    // Donation Text - Add padding container
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: pw.RichText(
                        text: pw.TextSpan(
                          style: pw.TextStyle(
                            fontSize: 13,
                            color: PdfColors.black,
                            height: 2.8,
                            font: pw.Font.times(),

                          ),
                          children: [
                            pw.TextSpan(
                              text: 'VIDHYAKAANTHI FOUNDATION',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,color: PdfColor.fromInt(0xFF1F2C58),
                                font: pw.Font.helveticaBold(),
                              ),
                            ),
                            pw.TextSpan(
                              text: ' is thankful to ',
                              style: pw.TextStyle(font: pw.Font.times()),
                            ),
                            pw.TextSpan(
                              text: donation.donorName,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58), // Dark blue color
                              ),
                            ),
                            pw.TextSpan(
                              text: ' Address: ',
                              style: pw.TextStyle(
                                font: pw.Font.times(), // Regular label (not bold)
                              ),
                            ),
                            pw.TextSpan(
                              text: donation.address,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58),
                              ),
                            ),
                            pw.TextSpan(
                              text: ' Email: ',
                              style: pw.TextStyle(
                                font: pw.Font.times(), // Regular label (not bold)
                              ),
                            ),
                            pw.TextSpan(
                              text: donation.email,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58), // Dark blue color
                              ),
                            ),
                            pw.TextSpan(
                              text: ' Contact No: ',
                              style: pw.TextStyle(
                                font: pw.Font.times(), // Regular label (not bold)
                              ),
                            ),
                            pw.TextSpan(
                              text: donation.phone,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58),
                              ),
                            ),
                            pw.TextSpan(
                              text: ' Pan No: ',
                              style: pw.TextStyle(
                                font: pw.Font.times(), // Regular label (not bold)
                              ),
                            ),
                            pw.TextSpan(
                              text: donation.pan,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58),
                              ),
                            ),
                            pw.TextSpan(
                              text: ' for kind donation of ',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: pw.Font.times(),
                              ),
                            ),
                            pw.TextSpan(
                              text: 'Rs: $amountStr/-.',
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), color: PdfColor.fromInt(0xFF1F2C58), // ✅ Bold value
                              ),
                            ),
                            pw.TextSpan(
                              text: ' ( $amountInWords in INR)',
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58),
                              ),
                            ),
                            pw.TextSpan(
                              text: ' for ',
                              style: pw.TextStyle(font: pw.Font.times()),
                            ),
                            pw.TextSpan(
                              text: donation.projectName,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(), // ✅ Bold value
                                color: PdfColor.fromInt(0xFF1F2C58),
                              ),
                            ),
                            if (donation.projectName != 'Custom')
                              pw.TextSpan(
                                text: ' ($formattedAmount)',
                                style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(), // ✅ Bold value
                                  color: PdfColor.fromInt(0xFF1F2C58),
                                ),
                              ),
                            pw.TextSpan(
                              text: '.',
                              style: pw.TextStyle(font: pw.Font.times()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    // Signature
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.black,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Authorised Sign.',
                              style: pw.TextStyle(
                                fontSize: 11,
                                font: pw.Font.helveticaBold(), color: PdfColor.fromInt(0xFF1F2C58), // ✅ Bold label
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 30),
                    // Horizontal line before Thank You Letter
                    pw.Container(
                      width: double.infinity,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 15),
                    // Thank You Letter Section
                    pw.Center(
                      child: pw.Text(
                        'Thank You Letter',
                        style: pw.TextStyle(
                          fontSize: 22,
                          font: pw.Font.helveticaBold(), // ✅ Built-in bold font for thick appearance
                          color: PdfColor.fromInt(0xFF1F2C58), // Dark blue color
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    // Thank You Text - Add padding container
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              style: pw.TextStyle(
                                fontSize: 12,
                                height: 1.8,
                                font: pw.Font.times(),
                              ),
                              children: [
                                pw.TextSpan(
                                  text: 'VIDHYAKAANTHI FOUNDATION',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,color: PdfColor.fromInt(0xFF1F2C58),
                                      font: pw.Font.helveticaBold(),
                                  ),
                                ),
                                pw.TextSpan(
                                  text: ' is Govt. Registered organization working for Welfare of Women & Children since $foundationYear. We are continuously supporting in the field of Education, Health, Youth, Poverty, Livelihood and Community Development. Our aim is to make every individual in the Society should be Self-dependent and raise the quality of life in every aspect. Your Donation would help us to feed children, provide quality education, digital education, support street needies.',
                                  style: pw.TextStyle(font: pw.Font.times()),
                                ),
                              ],
                            ),
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 15),
                          pw.RichText(
                            text: pw.TextSpan(
                              style: pw.TextStyle(
                                fontSize: 12,
                                height: 1.8,
                                font: pw.Font.times(),
                              ),
                              children: [
                                pw.TextSpan(
                                  text: 'Your Donation will go a long way to inspire the people to donate to the NGO who are. Donors like you have harnessed the potential of our young staff and encouraged us to work with sincerity and commitment. We are enclosing a receipt against your donation, along with this letter. We wish to have a long term relationship and good trust with you to serve the society. ',
                                  style: pw.TextStyle(font: pw.Font.times()),
                                ),
                                pw.TextSpan(
                                  text: 'Thank for your Support. Keep Supporting Us.',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(0xFF1F2C58),
                                      font: pw.Font.helveticaBold(),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: pw.TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    // Tax Benefit inside the blue box

                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              // Footer Contact Information
                pw.Center(
                  child: pw.Text(
                    'Your Donation is eligible for 50% tax benefit under section 80G of Income tax act.',
                    style: pw.TextStyle(
                      fontSize: 11,
                      font: pw.Font.helveticaBold(), // ✅ Bold tax benefit text
                      color: PdfColor.fromInt(0xFF1F2C58), // Dark blue color
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Contact Information - placed just under the outer border line
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Center(
              child: pw.Text(
                'Mobile No. $mobileNumber | Email: $emailAddress | Website: $website',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey800,
                  font: pw.Font.times(),
                ),
              ),
            ),
          ),
            ],
          );

        },
      ),
    );

    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_$receiptNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
