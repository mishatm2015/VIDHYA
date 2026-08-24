class ProjectModel {
  final String? id;
  final String name;
  final double amount;

  ProjectModel({
    this.id,
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
    };
  }

  factory ProjectModel.fromMap(String id, Map<String, dynamic> map) {
    // Handle amount as both string and number
    double amount = 0;
    if (map['amount'] != null) {
      if (map['amount'] is String) {
        amount = double.tryParse(map['amount'] as String) ?? 0;
      } else if (map['amount'] is num) {
        amount = (map['amount'] as num).toDouble();
      }
    }
    
    return ProjectModel(
      id: id,
      name: map['name'] ?? '',
      amount: amount,
    );
  }
}
