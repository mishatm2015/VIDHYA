import 'package:pdf/pdf.dart';

enum PdfThemeColor {
  blue,
  green,
  purple,
  teal,
  orange,
}

class PdfTheme {
  static PdfColor getPrimaryColor(PdfThemeColor theme) {
    switch (theme) {
      case PdfThemeColor.blue:
        return PdfColors.blue;
      case PdfThemeColor.green:
        return PdfColor.fromInt(0xFF4CAF50); // Green
      case PdfThemeColor.purple:
        return PdfColor.fromInt(0xFF9C27B0); // Purple
      case PdfThemeColor.teal:
        return PdfColor.fromInt(0xFF009688); // Teal
      case PdfThemeColor.orange:
        return PdfColor.fromInt(0xFFFF9800); // Orange
    }
  }

  static PdfColor getLightColor(PdfThemeColor theme) {
    switch (theme) {
      case PdfThemeColor.blue:
        return PdfColors.lightBlue;
      case PdfThemeColor.green:
        return PdfColor.fromInt(0xFFC8E6C9); // Light Green
      case PdfThemeColor.purple:
        return PdfColor.fromInt(0xFFE1BEE7); // Light Purple
      case PdfThemeColor.teal:
        return PdfColor.fromInt(0xFFB2DFDB); // Light Teal
      case PdfThemeColor.orange:
        return PdfColor.fromInt(0xFFFFE0B2); // Light Orange
    }
  }
}
