import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/rental_history.dart';
import '../widgets/student_detail_modal.dart';
import 'qr_scan_screen.dart';
import 'all_students_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Stream<QuerySnapshot> getActiveRentals() {
    return FirebaseFirestore.instance
        .collection('history')
        .where('status', whereIn: ['renting', 'late'])
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildHeader(context),
          _buildActionCards(context),
          _buildActiveRentalsHeader(context),
          _buildActiveRentalsList(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Device Manager',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your devices efficiently',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildActionCard(
            context,
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            color: Colors.blue,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanScreen()),
                ),
          ),
          const SizedBox(width: 16),
          _buildActionCard(
            context,
            icon: Icons.list_alt,
            label: 'All Data',
            color: Colors.green,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllStudentsScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRentalsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Rentals',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                ),
            icon: const Icon(Icons.history),
            label: const Text('History'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRentalsList(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: getActiveRentals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered =
              snapshot.data!.docs
                  .map((doc) => RentalHistory.fromFirestore(doc))
                  .where((rental) {
                    final rentDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(rental.timestamp.toDate());
                    if (rental.status == 'renting') {
                      return true;
                    }
                    if (rental.status == 'late' && rentDate == today) {
                      return true;
                    }
                    return false;
                  })
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active rentals',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: filtered.length,
            itemBuilder:
                (context, index) => _buildRentalCard(context, filtered[index]),
          );
        },
      ),
    );
  }

  Widget _buildRentalCard(BuildContext context, RentalHistory rental) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showStudentDetails(context, rental),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(rental.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    rental.studentName[0],
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(rental.status),
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
                      rental.studentName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rental.grade} • ${rental.brand}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(rental.status),
                          size: 16,
                          color: _getStatusColor(rental.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rental.status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(rental.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.Hm().format(rental.rentDate.toDate()),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(rental.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd/MM').format(rental.rentDate.toDate()),
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(rental.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  void _showStudentDetails(BuildContext context, RentalHistory rental) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StudentDetailModal(
            student: Student(
              id: rental.studentId,
              studentName: rental.studentName,
              grade: rental.grade,
              phoneBrand: rental.brand,
              status: rental.status,
              adminName: rental.adminName,
              startTime:
                  '${DateFormat('dd/MM HH:mm').format(rental.rentDate.toDate())} - ${DateFormat('dd/MM HH:mm').format(rental.returnDate.toDate())}',
              backTime:
                  rental.actualReturnDate != null
                      ? DateFormat(
                        'dd/MM HH:mm',
                      ).format(rental.actualReturnDate!.toDate())
                      : null,
            ),
          ),
    );
  }
}
