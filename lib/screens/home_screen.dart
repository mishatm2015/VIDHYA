import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  double _totalCollection = 0;
  int _donorsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Daily':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = now;
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case 'Custom':
        if (_startDate != null && _endDate != null) {
          startDate = _startDate;
          endDate = _endDate;
        }
        break;
    }

    final stats = await firestoreService.getDashboardStats(
      startDate: startDate,
      endDate: endDate,
    );

    setState(() {
      _totalCollection = stats['totalCollection'] ?? 0.0;
      _donorsCount = stats['donorsCount'] ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedFilter = 'Custom';
      });
      _loadStats();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Vidhyakaanthi Foundation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section
              const Text(
                'Filter by Period',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    title: 'All',
                    selected: _selectedFilter == 'All',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadStats();
                    },
                  ),
                  _FilterChip(
                    title: 'Daily',
                    selected: _selectedFilter == 'Daily',
                    onTap: () {
                      setState(() => _selectedFilter = 'Daily');
                      _loadStats();
                    },
                  ),
                  _FilterChip(
                    title: 'Weekly',
                    selected: _selectedFilter == 'Weekly',
                    onTap: () {
                      setState(() => _selectedFilter = 'Weekly');
                      _loadStats();
                    },
                  ),
                  _FilterChip(
                    title: 'Monthly',
                    selected: _selectedFilter == 'Monthly',
                    onTap: () {
                      setState(() => _selectedFilter = 'Monthly');
                      _loadStats();
                    },
                  ),
                  _FilterChip(
                    title: 'Custom',
                    selected: _selectedFilter == 'Custom',
                    onTap: _selectCustomDateRange,
                  ),
                ],
              ),
              if (_selectedFilter == 'Custom' && _startDate != null && _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Selected: ${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Statistics Cards
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _StatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Total Collection',
                  value: _totalCollection > 0
                      ? '₹${NumberFormat('#,##,###.00').format(_totalCollection)}'
                      : '₹ 0',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _StatCard(
                  icon: Icons.groups,
                  title: 'Donors Count',
                  value: _donorsCount.toString(),
                  color: Colors.green,
                ),
                const SizedBox(height: 40),

                // Empty State
                if (_totalCollection == 0 && _donorsCount == 0)
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No donations yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(title),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: selected ? Colors.blue : Colors.black,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 28,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
