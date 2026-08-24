import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import 'pdf_preview_screen.dart';

class PreviewScreen extends StatefulWidget {
  final DonationModel donation;

  const PreviewScreen({super.key, required this.donation});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isGenerating = false;

  Future<void> _confirmAndGeneratePdf() async {
    setState(() => _isGenerating = true);

    try {
      // Generate PDF
      final pdfFile = await PdfService.generatePdf(widget.donation);

      // Save to Firestore
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final donationId = await firestoreService.addDonation(widget.donation);

      // Upload to Firebase Storage
      final storageService = StorageService();
      final pdfBytes = await pdfFile.readAsBytes();
      final pdfUrl = await storageService.uploadPdfFromBytes(pdfBytes, donationId);

      // Update donation with PDF URL
      await firestoreService.updateDonationPdfUrl(donationId, pdfUrl);

      // Update donation model
      final updatedDonation = widget.donation.copyWith(
        id: donationId,
        pdfUrl: pdfUrl,
      );

      if (!mounted) return;

      // Show PDF Preview
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(
            pdfFile: pdfFile,
            donation: updatedDonation,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donor Details Section
            _buildSection(
              'Donor Details',
              [
                _buildDetailRow('Donor Name', widget.donation.donorName),
                _buildDetailRow('Email', widget.donation.email),
                _buildDetailRow('Phone', widget.donation.phone),
                _buildDetailRow('PAN Card', widget.donation.pan),
                _buildDetailRow('Address', widget.donation.address),
              ],
            ),
            const SizedBox(height: 24),

            // Donation Details Section
            _buildSection(
              'Donation Details',
              [
                _buildDetailRow('Project Name', widget.donation.projectName),
                _buildDetailRow(
                  'Amount',
                  '₹${widget.donation.amount.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Date',
                  '${widget.donation.createdAt.day}/${widget.donation.createdAt.month}/${widget.donation.createdAt.year}',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _confirmAndGeneratePdf,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm & Generate PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
