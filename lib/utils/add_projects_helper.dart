import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Helper class to add projects to Firebase
/// Run this once to populate all projects
class AddProjectsHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Map<String, dynamic>> projects = [
    {
      'name': 'FEED A CHILD FOR A MONTH',
      'amount': 2975,
    },
    {
      'name': 'FEED A FAMILY FOR 2 MONTH',
      'amount': 7950,
    },
    {
      'name': 'EDUCATION 2 GIRL CHILD FOR 1 YEAR',
      'amount': 19900,
    },
    {
      'name': 'NUTRITION FOOD FOR 1 ORPHAN CHILD',
      'amount': 2850,
    },
    {
      'name': 'EDUCATION 1 GIRL CHILD FOR 6 MONTHS',
      'amount': 6900,
    },
    {
      'name': 'FEED A FAMILY FOR 2 WEEK',
      'amount': 2550,
    },
    {
      'name': 'EDUCATION 1 GIRL CHILD 1 YEAR',
      'amount': 9950,
    },
    {
      'name': 'FULL DAY MEAL FOR 400 CHILDREN',
      'amount': 68500,
    },
    {
      'name': 'ABANDONED CHILD FULL CARE 1 YEAR',
      'amount': 72000,
    },
    {
      'name': 'HYGENIE KIT FOR 6 PEOPLE',
      'amount': 1850,
    },
    {
      'name': 'FEED 3 STREET CHILDREN FOR A MONTH',
      'amount': 9905,
    },
    {
      'name': 'INFANT GIRL CHILD SUPPORT 1 YEAR',
      'amount': 46800,
    },
    {
      'name': 'FEED 10 OLD AGED PEOPLE FOR 1 YEAR',
      'amount': 295000,
    },
    {
      'name': 'FEED 10 OLD AGED PEOPLE FOR 1 MONTH',
      'amount': 29500,
    },
  ];

  /// Add all projects to Firebase
  /// Returns the number of projects added
  static Future<int> addAllProjects() async {
    int addedCount = 0;
    try {
      for (var project in projects) {
        // Check if project already exists (by name)
        final existing = await _firestore
            .collection('projects')
            .where('name', isEqualTo: project['name'])
            .get();

        if (existing.docs.isEmpty) {
          // Project doesn't exist, add it
          await _firestore.collection('projects').add(project);
          addedCount++;
          debugPrint('Added project: ${project['name']}');
        } else {
          debugPrint('Project already exists: ${project['name']}');
        }
      }
      debugPrint('Total projects added: $addedCount');
      return addedCount;
    } catch (e) {
      debugPrint('Error adding projects: $e');
      rethrow;
    }
  }

  /// Add a single project
  static Future<void> addProject(String name, double amount) async {
    try {
      await _firestore.collection('projects').add({
        'name': name,
        'amount': amount,
      });
      debugPrint('Added project: $name');
    } catch (e) {
      debugPrint('Error adding project: $e');
      rethrow;
    }
  }
}
