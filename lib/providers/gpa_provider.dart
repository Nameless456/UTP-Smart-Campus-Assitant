import 'package:flutter/material.dart';
import 'package:flutter_gemini/models/course.dart';
import 'package:flutter_gemini/models/semester.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class GpaProvider extends ChangeNotifier {
  List<Semester> _semesters = [];
  static const String _gpaBoxName = 'gpa_data';

  List<Semester> get semesters => _semesters;

  // Calculate overall CGPA
  double get cgpa {
    if (_semesters.isEmpty) return 0.0;

    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var semester in _semesters) {
      for (var course in semester.courses) {
        totalPoints += course.gradePoint * course.creditHours;
        totalCredits += course.creditHours;
      }
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // Get total credit hours across all semesters
  int get totalCreditHours {
    return _semesters.fold(
      0,
      (sum, semester) => sum + semester.totalCreditHours,
    );
  }

  // Initialize and load data from Hive
  Future<void> init() async {
    await _loadFromHive();
  }

  // Load semesters from Hive
  Future<void> _loadFromHive() async {
    try {
      final box = await Hive.openBox(_gpaBoxName);
      final data = box.get('semesters');

      if (data != null && data is List) {
        _semesters = data
            .map(
              (semesterMap) =>
                  Semester.fromMap(Map<String, dynamic>.from(semesterMap)),
            )
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading GPA data: $e');
    }
  }

  // Save semesters to Hive
  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox(_gpaBoxName);
      final data = _semesters.map((semester) => semester.toMap()).toList();
      await box.put('semesters', data);
    } catch (e) {
      debugPrint('Error saving GPA data: $e');
    }
  }

  // Add a new semester
  Future<void> addSemester(String name) async {
    final newSemester = Semester(
      id: const Uuid().v4(),
      name: name,
      courses: [],
    );
    _semesters.add(newSemester);
    await _saveToHive();
    notifyListeners();
  }

  // Remove a semester
  Future<void> removeSemester(String semesterId) async {
    _semesters.removeWhere((semester) => semester.id == semesterId);
    await _saveToHive();
    notifyListeners();
  }

  // Add a course to a semester
  Future<void> addCourse(
    String semesterId,
    String courseName,
    int creditHours,
    String grade,
  ) async {
    final semesterIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semesterIndex != -1) {
      final newCourse = Course(
        id: const Uuid().v4(),
        name: courseName,
        creditHours: creditHours,
        grade: grade,
      );

      final updatedCourses = List<Course>.from(
        _semesters[semesterIndex].courses,
      )..add(newCourse);

      _semesters[semesterIndex] = _semesters[semesterIndex].copyWith(
        courses: updatedCourses,
      );

      await _saveToHive();
      notifyListeners();
    }
  }

  // Remove a course from a semester
  Future<void> removeCourse(String semesterId, String courseId) async {
    final semesterIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semesterIndex != -1) {
      final updatedCourses = _semesters[semesterIndex].courses
          .where((course) => course.id != courseId)
          .toList();

      _semesters[semesterIndex] = _semesters[semesterIndex].copyWith(
        courses: updatedCourses,
      );

      await _saveToHive();
      notifyListeners();
    }
  }

  // Update a course
  Future<void> updateCourse(
    String semesterId,
    String courseId,
    String courseName,
    int creditHours,
    String grade,
  ) async {
    final semesterIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semesterIndex != -1) {
      final courseIndex = _semesters[semesterIndex].courses.indexWhere(
        (c) => c.id == courseId,
      );

      if (courseIndex != -1) {
        final updatedCourses = List<Course>.from(
          _semesters[semesterIndex].courses,
        );
        updatedCourses[courseIndex] = Course(
          id: courseId,
          name: courseName,
          creditHours: creditHours,
          grade: grade,
        );

        _semesters[semesterIndex] = _semesters[semesterIndex].copyWith(
          courses: updatedCourses,
        );

        await _saveToHive();
        notifyListeners();
      }
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    _semesters.clear();
    await _saveToHive();
    notifyListeners();
  }
}
