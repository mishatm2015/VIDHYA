import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String? id;
  final String donorName;
  final String email;
  final String phone;
  final String pan;
  final String address;
  final String projectName;
  final double amount;
  final String? pdfUrl;
  final DateTime createdAt;

  DonationModel({
    this.id,
    required this.donorName,
    required this.email,
    required this.phone,
    required this.pan,
    required this.address,
    required this.projectName,
    required this.amount,
    this.pdfUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'donorName': donorName,
      'email': email,
      'phone': phone,
      'pan': pan,
      'address': address,
      'projectName': projectName,
      'amount': amount,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt,
    };
  }

  factory DonationModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime createdAt;
    if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    return DonationModel(
      id: id,
      donorName: map['donorName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      pan: map['pan'] ?? '',
      address: map['address'] ?? '',
      projectName: map['projectName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      pdfUrl: map['pdfUrl'],
      createdAt: createdAt,
    );
  }

  DonationModel copyWith({
    String? id,
    String? donorName,
    String? email,
    String? phone,
    String? pan,
    String? address,
    String? projectName,
    double? amount,
    String? pdfUrl,
    DateTime? createdAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorName: donorName ?? this.donorName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pan: pan ?? this.pan,
      address: address ?? this.address,
      projectName: projectName ?? this.projectName,
      amount: amount ?? this.amount,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
