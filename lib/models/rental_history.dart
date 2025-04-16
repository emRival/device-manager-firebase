import 'package:cloud_firestore/cloud_firestore.dart';

class RentalHistory {
  final String id;
  final String studentId;
  final String studentName;
  final String grade;
  final String brand;
  final String status;
  final String adminName;
  final Timestamp rentDate;
  final Timestamp returnDate;
  final Timestamp? actualReturnDate;
  final Timestamp timestamp;


  RentalHistory({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.brand,
    required this.status,
    required this.adminName,
    required this.rentDate,
    required this.returnDate,
    this.actualReturnDate,
    required this.timestamp,

  });

  factory RentalHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalHistory(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      grade: data['grade'] ?? '',
      brand: data['brand'] ?? '',
      status: data['status'] ?? '',
      adminName: data['adminName'] ?? '',
      rentDate: data['rentDate'] as Timestamp,
      returnDate: data['returnDate'] as Timestamp,
      actualReturnDate: data['actualReturnDate'] as Timestamp?,
      timestamp: data['timestamp'] as Timestamp,
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'grade': grade,
      'brand': brand,
      'status': status,
      'adminName': adminName,
      'rentDate': rentDate,
      'returnDate': returnDate,
      'actualReturnDate': actualReturnDate,
      'timestamp': timestamp,

    };
  }
}
