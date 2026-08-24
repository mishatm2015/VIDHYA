import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../models/donation_model.dart';
import '../models/project_model.dart';
import '../services/firestore_service.dart';
import 'preview_screen.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panController = TextEditingController();
  final _addressController = TextEditingController();
  final _customAmountController = TextEditingController();

  ProjectModel? _selectedProject;
  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = true;
  bool _useCustomAmount = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final projects = await firestoreService.getProjects();
      setState(() {
        _projects = projects;
        _isLoadingProjects = false;
      });
      
      if (projects.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No projects found. Please add projects in Firebase Console.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading projects: $e');
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadProjects,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _onProjectSelected(ProjectModel? project) {
    setState(() {
      _selectedProject = project;
      if (project != null) {
        _customAmountController.text = project.amount.toStringAsFixed(2);
        _useCustomAmount = false;
      }
    });
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate amount
    double amount;
    if (_selectedProject != null && !_useCustomAmount) {
      amount = _selectedProject!.amount;
    } else {
      if (_customAmountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter amount or select a project')),
        );
        return;
      }
      amount = double.tryParse(_customAmountController.text) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }
    }

    final donation = DonationModel(
      donorName: _donorNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      pan: _panController.text.trim(),
      address: _addressController.text.trim(),
      projectName: _selectedProject?.name ?? 'Custom',
      amount: amount,
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(donation: donation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Donation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Donor Name
            TextFormField(
              controller: _donorNameController,
              decoration: const InputDecoration(
                labelText: 'Donor Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter donor name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // PAN Card
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(
                labelText: 'PAN Card *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter PAN card';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Contact Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Project Dropdown
            const Text(
              'Select Project (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoadingProjects)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_projects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'No projects found',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please add projects in Firebase Console. See ADD_PROJECTS.md for instructions.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loadProjects,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<ProjectModel>(
                  value: _selectedProject,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Project',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(
                      Icons.folder_special,
                      color: Colors.blue,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                    size: 28,
                  ),
                  items: [
                    DropdownMenuItem<ProjectModel>(
                      value: null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'None (Custom Amount)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._projects.map((project) {
                      return DropdownMenuItem<ProjectModel>(
                        value: project,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  Text(
                                    project.amount.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      const Text(
                        'None (Custom Amount)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ..._projects.map((project) {
                        return Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ];
                  },
                  onChanged: _onProjectSelected,
                ),
              ),
            const SizedBox(height: 16),

            // Custom Amount
            Row(
              children: [
                Checkbox(
                  value: _useCustomAmount || _selectedProject == null,
                  onChanged: (value) {
                    setState(() {
                      _useCustomAmount = value ?? false;
                      if (_useCustomAmount) {
                        _selectedProject = null;
                        _customAmountController.clear();
                      }
                    });
                  },
                ),
                const Expanded(
                  child: Text('Use Custom Amount'),
                ),
              ],
            ),
            if (_useCustomAmount || _selectedProject == null)
              TextFormField(
                controller: _customAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                enabled: _useCustomAmount || _selectedProject == null,
                validator: (value) {
                  if ((_selectedProject == null || _useCustomAmount) &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter amount';
                  }
                  if (value != null && value.isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                  }
                  return null;
                },
              ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Preview & Submit',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
