import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/rental_history.dart';
import '../widgets/student_detail_modal.dart';

class AllStudentsScreen extends StatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen> {
  final ValueNotifier<String> _selectedFilter = ValueNotifier<String>('all');
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _selectedFilter.dispose();
    _searchQuery.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getAllHistory() {
    return FirebaseFirestore.instance
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  List<RentalHistory> _filterHistory(
    List<QueryDocumentSnapshot> docs,
    String filter,
    String query,
  ) {
    return docs.map((doc) => RentalHistory.fromFirestore(doc)).where((history) {
      final matchesFilter = filter == 'all' || history.status == filter;
      final matchesQuery =
          query.isEmpty ||
          history.studentName.toLowerCase().contains(query.toLowerCase()) ||
          history.grade.toLowerCase().contains(query.toLowerCase()) ||
          history.brand.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'late':
        return Colors.red;
      case 'renting':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'late':
        return Icons.warning;
      case 'renting':
        return Icons.access_time;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'All Device History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [_buildSearchBar(), _buildFilterChips(), _buildHistoryList()],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search by name, grade, or device...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<String>(
        valueListenable: _selectedFilter,
        builder: (context, selectedFilter, _) {
          return Row(
            children: [
              _buildFilterChip('All', 'all', selectedFilter),
              const SizedBox(width: 8),
              _buildFilterChip('Renting', 'renting', selectedFilter),
              const SizedBox(width: 8),
              _buildFilterChip('Late', 'late', selectedFilter),
              const SizedBox(width: 8),
              _buildFilterChip('Returned', 'returned', selectedFilter),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedFilter) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _selectedFilter.value = value;
        }
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: getAllHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No history available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ValueListenableBuilder<String>(
            valueListenable: _selectedFilter,
            builder: (context, filter, _) {
              return ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, query, _) {
                  final filtered = _filterHistory(
                    snapshot.data!.docs,
                    filter,
                    query,
                  );

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final history = filtered[index];
                      return _buildHistoryCard(context, history);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, RentalHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showStudentDetails(context, history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(history.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        history.studentName[0],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(history.status),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.studentName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${history.grade} • ${history.brand}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(history.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(history.status),
                          size: 14,
                          color: _getStatusColor(history.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          history.status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(history.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rent Date',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(history.rentDate.toDate()),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Time',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(history.rentDate.toDate()),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Processed by: ${history.adminName}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, RentalHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StudentDetailModal(
            student: Student(
              id: history.studentId,
              studentName: history.studentName,
              grade: history.grade,
              phoneBrand: history.brand,
              status: history.status,
              adminName: history.adminName,
              startTime:
                  '${DateFormat('dd/MM HH:mm').format(history.rentDate.toDate())} - ${DateFormat('dd/MM HH:mm').format(history.returnDate.toDate())}',
              backTime:
                  history.actualReturnDate != null
                      ? DateFormat(
                        'dd/MM HH:mm',
                      ).format(history.actualReturnDate!.toDate())
                      : null,
            ),
          ),
    );
  }
}
