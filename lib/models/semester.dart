import 'package:flutter_gemini/models/course.dart';

class Semester {
  final String id;
  final String name;
  final List<Course> courses;

  Semester({required this.id, required this.name, required this.courses});

  // Calculate GPA for this semester
  double get gpa {
    if (courses.isEmpty) return 0.0;

    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var course in courses) {
      totalPoints += course.gradePoint * course.creditHours;
      totalCredits += course.creditHours;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // Get total credit hours
  int get totalCreditHours {
    return courses.fold(0, (sum, course) => sum + course.creditHours);
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((course) => course.toMap()).toList(),
    };
  }

  // Create from map
  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      id: map['id'],
      name: map['name'],
      courses: (map['courses'] as List)
          .map((courseMap) => Course.fromMap(courseMap))
          .toList(),
    );
  }

  // Copy with method for immutability
  Semester copyWith({String? id, String? name, List<Course>? courses}) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      courses: courses ?? this.courses,
    );
  }
}
