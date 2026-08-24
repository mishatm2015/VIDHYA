import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation_model.dart';

class PdfPreviewScreen extends StatefulWidget {
  final File pdfFile;
  final DonationModel donation;
  final bool autoShare;

  const PdfPreviewScreen({
    super.key,
    required this.pdfFile,
    required this.donation,
    this.autoShare = true,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically show share dialog when screen loads
    if (widget.autoShare) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showShareOptions();
      });
    }
  }

  Future<void> _showShareOptions() async {
    if (!mounted) return;
    
    await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Receipt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context, 'share');
                _sharePdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Share via WhatsApp'),
              onTap: () {
                Navigator.pop(context, 'whatsapp');
                _shareViaWhatsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Share via Email'),
              onTap: () {
                Navigator.pop(context, 'email');
                _shareViaEmail();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdf() async {
    try {
      await Share.shareXFiles(
        [XFile(widget.pdfFile.path)],
        text: 'Donation Receipt - ${widget.donation.donorName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
      debugPrint('Error sharing PDF: $e');
    }
  }

  Future<void> _shareViaWhatsApp() async {
    try {
      // First share the PDF file
      await Share.shareXFiles(
        [XFile(widget.pdfFile.path)],
        text: 'Donation Receipt - ${widget.donation.donorName}\nAmount: ₹${widget.donation.amount.toStringAsFixed(2)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing via WhatsApp: $e')),
        );
      }
      debugPrint('Error sharing via WhatsApp: $e');
    }
  }

  Future<void> _shareViaEmail() async {
    try {
      // Share the PDF file with email intent
      await Share.shareXFiles(
        [XFile(widget.pdfFile.path)],
        text: 'Donation Receipt - ${widget.donation.donorName}\n\nAmount: ₹${widget.donation.amount.toStringAsFixed(2)}\nProject: ${widget.donation.projectName}',
        subject: 'Donation Receipt - ${widget.donation.donorName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing via Email: $e')),
        );
      }
      debugPrint('Error sharing via Email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.chat),
                    SizedBox(width: 8),
                    Text('WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Email'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _sharePdf();
                  break;
                case 'whatsapp':
                  _shareViaWhatsApp();
                  break;
                case 'email':
                  _shareViaEmail();
                  break;
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => widget.pdfFile.readAsBytes(),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.check),
        label: const Text('Done'),
      ),
    );
  }
}
