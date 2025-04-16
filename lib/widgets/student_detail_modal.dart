import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';

class StudentDetailModal extends StatelessWidget {
  final Student student;

  const StudentDetailModal({super.key, required this.student});

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildStudentInfo(context),
          _buildRentalInfo(context),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(student.status).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(student.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                student.studentName[0],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(student.status),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(student.status),
                      size: 16,
                      color: _getStatusColor(student.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      student.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(student.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Grade', student.grade),
          const SizedBox(height: 8),
          _buildInfoRow('Device', student.phoneBrand),
          const SizedBox(height: 8),
          _buildInfoRow('Processed by', student.adminName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Text(
          ':',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRentalInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rental Period',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeRow('Rent Date', student.startTime.split(' - ')[0]),
          const SizedBox(height: 8),
          _buildTimeRow('Return Date', student.startTime.split(' - ')[1]),
          if (student.backTime != null) ...[
            const SizedBox(height: 8),
            _buildTimeRow('Actual Return', student.backTime!),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String time) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Text(
          ':',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            time,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle return action
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
