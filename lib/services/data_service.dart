import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String grade;
  final String brand;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.brand,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['ID'].toString(),
      name: json['NAME'],
      grade: json['GRADE'],
      brand: json['BRAND'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'NAME': name,
      'GRADE': grade,
      'BRAND': brand,
    }; // Key diubah ke uppercase
  }
}

class Rental {
  final String studentId;
  final String studentName;
  final String grade;
  final String brand;
  final DateTime rentDate;
  final DateTime? returnDate;
  final String status; // 'active' or 'returned'
  final String adminName; // Added admin name field

  Rental({
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.brand,
    required this.rentDate,
    this.returnDate,
    required this.status,
    required this.adminName, // Added to constructor
  });

  factory Rental.fromFirestore(Map<String, dynamic> data) {
    return Rental(
      studentId: data['studentId'],
      studentName: data['studentName'],
      grade: data['grade'],
      brand: data['brand'],
      rentDate: (data['rentDate'] as Timestamp).toDate(),
      returnDate:
          data['returnDate'] != null
              ? (data['returnDate'] as Timestamp).toDate()
              : null,
      status: data['status'],
      adminName: data['adminName'], // Added to fromFirestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'grade': grade,
      'brand': brand,
      'rentDate': Timestamp.fromDate(rentDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status,
      'adminName': adminName, // Added to toFirestore
    };
  }
}

class DataService {
  static const String _studentsKey = 'students_data';
  final String _apiUrl =
      'https://script.google.com/macros/s/AKfycbxAjbAl90KG79jP5cjx4hnbUUm1Wimj-gr39UqWuho5gPBFlnOIU9PF2-8imzanmy44/exec';

  Future<List<Student>> fetchStudentsFromAPI() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Student> students =
            data.map((item) => Student.fromJson(item)).toList();

        print('Fetched ${students.length} students from API');

        // Save to local storage
        await _saveStudentsLocally(students);

        return students;
      } else {
        throw Exception('Failed to load students data');
      }
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<void> _saveStudentsLocally(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = students.map((student) => student.toJson()).toList();
    await prefs.setString(_studentsKey, json.encode(studentsJson));

    print('Saved ${students.length} students to local storage:');
    print(studentsJson); // Debug print
  }

  Future<List<Student>> getLocalStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = prefs.getString(_studentsKey);

    if (studentsJson != null && studentsJson.isNotEmpty) {
      try {
        final List<dynamic> data = json.decode(studentsJson);
        print('Decoded data: $data');
        print('Decoded data type: ${data.runtimeType}');
        print('First item type: ${data.first.runtimeType}');

        // Ensure that each item is a Map<String, dynamic>
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return Student.fromJson(item);
          } else {
            throw Exception('Invalid data format for student');
          }
        }).toList();
      } catch (e) {
        print('Error decoding students data: $e');
        return [];
      }
    } else {
      print('No students data found in SharedPreferences');
      return [];
    }
  }
}
