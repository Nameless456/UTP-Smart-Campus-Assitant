class Course {
  final String id;
  final String name;
  final int creditHours;
  final String grade;

  Course({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.grade,
  });

  //get grade point based on grade
  double get gradePoint {
    switch (grade.toUpperCase()) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.67;
      case 'B+':
        return 3.33;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.67;
      case 'C+':
        return 2.33;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.67;
      case 'D+':
        return 1.33;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  //convert to map for storage
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'creditHours': creditHours, 'grade': grade};
  }

  //create from map
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      creditHours: map['creditHours'],
      grade: map['grade'],
    );
  }
}
