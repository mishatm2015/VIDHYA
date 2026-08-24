import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/donation_model.dart';
import '../models/project_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Projects
  Future<List<ProjectModel>> getProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      return snapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      return [];
    }
  }

  Stream<List<ProjectModel>> getProjectsStream() {
    return _firestore.collection('projects').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Donations
  Future<String> addDonation(DonationModel donation) async {
    try {
      final docRef = await _firestore.collection('donations').add(donation.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding donation: $e');
      rethrow;
    }
  }

  Future<void> updateDonation(String id, DonationModel donation) async {
    try {
      await _firestore.collection('donations').doc(id).update(donation.toMap());
    } catch (e) {
      debugPrint('Error updating donation: $e');
      rethrow;
    }
  }

  Future<void> updateDonationPdfUrl(String id, String pdfUrl) async {
    try {
      await _firestore.collection('donations').doc(id).update({'pdfUrl': pdfUrl});
    } catch (e) {
      debugPrint('Error updating PDF URL: $e');
      rethrow;
    }
  }

  Stream<List<DonationModel>> getDonationsStream() {
    return _firestore
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<DonationModel>> getDonations() async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching donations: $e');
      return [];
    }
  }

  Future<List<DonationModel>> getDonationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Firestore requires composite index for multiple where clauses on same field
      // Fetch all and filter in memory as fallback
      final snapshot = await _firestore
          .collection('donations')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching donations by date range: $e');
      // Fallback: fetch all and filter
      try {
        final allSnapshot = await _firestore.collection('donations').get();
        final donations = allSnapshot.docs
            .map((doc) => DonationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .where((donation) {
              return donation.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  donation.createdAt.isBefore(endDate.add(const Duration(days: 1)));
            })
            .toList();
        return donations;
      } catch (e2) {
        debugPrint('Error in fallback: $e2');
        return [];
      }
    }
  }

  Future<Map<String, dynamic>> getDashboardStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      QuerySnapshot snapshot;
      
      if (startDate != null && endDate != null) {
        // Use a single range query - Firestore requires index for compound queries
        // For now, fetch all and filter in memory (or create composite index)
        snapshot = await _firestore
            .collection('donations')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();
      } else {
        snapshot = await _firestore.collection('donations').get();
      }

      double totalCollection = 0;
      Set<String> uniqueDonors = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalCollection += (data['amount'] ?? 0).toDouble();
        final phone = data['phone'] ?? '';
        if (phone.isNotEmpty) {
          uniqueDonors.add(phone);
        }
      }

      return {
        'totalCollection': totalCollection,
        'donorsCount': uniqueDonors.length,
      };
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      // Fallback: fetch all and filter in memory
      try {
        final allSnapshot = await _firestore.collection('donations').get();
        double totalCollection = 0;
        Set<String> uniqueDonors = {};

        for (var doc in allSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime docDate;
          if (data['createdAt'] is Timestamp) {
            docDate = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is DateTime) {
            docDate = data['createdAt'] as DateTime;
          } else {
            continue;
          }

          if (startDate != null && endDate != null) {
            if (docDate.isBefore(startDate) || docDate.isAfter(endDate)) {
              continue;
            }
          }

          totalCollection += (data['amount'] ?? 0).toDouble();
          final phone = data['phone'] ?? '';
          if (phone.isNotEmpty) {
            uniqueDonors.add(phone);
          }
        }

        return {
          'totalCollection': totalCollection,
          'donorsCount': uniqueDonors.length,
        };
      } catch (e2) {
        debugPrint('Error in fallback: $e2');
        return {'totalCollection': 0.0, 'donorsCount': 0};
      }
    }
  }
}
