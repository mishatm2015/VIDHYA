import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/donation_model.dart';
import '../services/firestore_service.dart';
import 'package:printing/printing.dart';
import 'pdf_preview_screen.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Recent Donations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by donor name or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Donations List
          Expanded(
            child: StreamBuilder<List<DonationModel>>(
              stream: Provider.of<FirestoreService>(context).getDonationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No donations found'),
                  );
                }

                var donations = snapshot.data!;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  donations = donations.where((donation) {
                    return donation.donorName.toLowerCase().contains(_searchQuery) ||
                        donation.phone.contains(_searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return _buildDonationCard(donation);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            donation.donorName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          donation.donorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Project: ${donation.projectName}'),
            Text('Date: ${dateFormat.format(donation.createdAt)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${donation.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (donation.pdfUrl != null)
              const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
          ],
        ),
        onTap: () {
          if (donation.pdfUrl != null) {
            _openPdf(donation.pdfUrl!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF not available')),
            );
          }
        },
      ),
    );
  }

  Future<void> _openPdf(String pdfUrl) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download PDF from Firebase Storage
      final response = await http.get(Uri.parse(pdfUrl));
      
      if (response.statusCode == 200) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Find the donation to pass to preview screen
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        final donations = await firestoreService.getDonations();
        final donation = donations.firstWhere(
          (d) => d.pdfUrl == pdfUrl,
          orElse: () => DonationModel(
            id: '',
            donorName: 'Unknown',
            email: '',
            phone: '',
            pan: '',
            address: '',
            projectName: 'Unknown',
            amount: 0.0,
            createdAt: DateTime.now(),
          ),
        );

        // Open PDF preview screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(
                pdfFile: file,
                donation: donation,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading PDF: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if still open
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: $e')),
        );
      }
    }
  }
}
