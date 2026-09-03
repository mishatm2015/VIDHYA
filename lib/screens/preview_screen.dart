import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  static const Color _primaryBlue = Color(0xFF1565C0);

  Future<void> _confirmAndGeneratePdf() async {
    setState(() => _isGenerating = true);

    try {
      final pdfFile = await PdfService.generatePdf(widget.donation);

      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final donationId = await firestoreService.addDonation(widget.donation);

      final storageService = StorageService();
      final pdfBytes = await pdfFile.readAsBytes();
      final pdfUrl =
          await storageService.uploadPdfFromBytes(pdfBytes, donationId);

      await firestoreService.updateDonationPdfUrl(donationId, pdfUrl);

      final updatedDonation = widget.donation.copyWith(
        id: donationId,
        pdfUrl: pdfUrl,
      );

      if (!mounted) return;

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

  String get _formattedDate {
    final d = widget.donation.createdAt;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Preview Donation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    title: 'Donor Details',
                    icon: Icons.person_outline,
                    children: [
                      _buildDetailItem('Donor Name', widget.donation.donorName),
                      _buildDetailItem('Email', widget.donation.email),
                      _buildDetailItem('Phone', widget.donation.phone),
                      _buildDetailItem('PAN Card', widget.donation.pan),
                      _buildDetailItem(
                        'Address',
                        widget.donation.address,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Donation Details',
                    icon: Icons.volunteer_activism_outlined,
                    children: [
                      _buildDetailItem(
                        'Project Name',
                        widget.donation.projectName,
                      ),
                      _buildDetailItem(
                        'Amount',
                        '₹${widget.donation.amount.toStringAsFixed(2)}',
                        valueStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                        ),
                      ),
                      _buildDetailItem(
                        'Date',
                        _formattedDate,
                        isLast: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isGenerating ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFFB0BEC5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _confirmAndGeneratePdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primaryBlue.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm & Generate PDF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: _primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFECEFF1)),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    TextStyle? valueStyle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF78909C),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF263238),
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}
