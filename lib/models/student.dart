class Student {
  final String id;
  final String studentName;
  final String grade;
  final String phoneBrand;
  final String status; // rent, putback, late
  final String adminName;
  final String startTime;
  final String? backTime;

  Student({
    required this.id,
    required this.studentName,
    required this.grade,
    required this.phoneBrand,
    required this.status,
    required this.adminName,
    required this.startTime,
    this.backTime,
  });

  // // For demo purposes, creating some sample data
  static List<Student> getSampleData() {
    final now = DateTime.now();
    return [
      Student(
        id: '1',
        studentName: 'John Doe',
        grade: '10A',
        phoneBrand: 'iPhone 13',
        status: 'rent',
        adminName: 'Admin 1',
        startTime: now.subtract(const Duration(hours: 2)).toString(),
      ),
      Student(
        id: '2',
        studentName: 'Jane Smith',
        grade: '11B',
        phoneBrand: 'Samsung S21',
        status: 'late',
        adminName: 'Admin 1',
        startTime: now.subtract(const Duration(days: 1)).toString(),
        backTime: now.subtract(const Duration(hours: 1)).toString(),
      ),
      Student(
        id: '3',
        studentName: 'Mike Johnson',
        grade: '12C',
        phoneBrand: 'Google Pixel 6',
        status: 'putback',
        adminName: 'Admin 2',
        startTime: now.subtract(const Duration(hours: 5)).toString(),
        backTime: now.toString(),
      ),
    ];
  }
}
