import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPdf(File pdfFile, String donationId) async {
    try {
      final year = DateTime.now().year;
      final ref = _storage.ref().child('receipts/$year/$donationId.pdf');
      
      await ref.putFile(pdfFile);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading PDF: $e');
      rethrow;
    }
  }

  Future<String> uploadPdfFromBytes(List<int> pdfBytes, String donationId) async {
    try {
      final year = DateTime.now().year;
      final ref = _storage.ref().child('receipts/$year/$donationId.pdf');
      
      await ref.putData(
        Uint8List.fromList(pdfBytes),
        SettableMetadata(contentType: 'application/pdf'),
      );
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading PDF from bytes: $e');
      rethrow;
    }
  }

  Future<void> deletePdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) return;
    try {
      final ref = _storage.refFromURL(pdfUrl);
      await ref.delete();
    } catch (e) {
      // PDF may already be missing; don't block donation delete
      debugPrint('Error deleting PDF: $e');
    }
  }
}
