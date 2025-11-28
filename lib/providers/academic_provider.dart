import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gemini/models/academic_record.dart';

class AcademicProvider extends ChangeNotifier {
  List<AcademicRecord> _records = [];
  Box<AcademicRecord>? _box;

  List<AcademicRecord> get records => _records;

  double get currentCGPA {
    if (_records.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCreditHours = 0;

    for (var record in _records) {
      totalPoints += record.gradePointValue * record.creditHours;
      totalCreditHours += record.creditHours;
    }

    return totalCreditHours == 0 ? 0.0 : totalPoints / totalCreditHours;
  }

  Map<int, List<AcademicRecord>> get recordsBySemester {
    final Map<int, List<AcademicRecord>> grouped = {};
    for (var record in _records) {
      final semester = record.semester ?? 1;
      if (!grouped.containsKey(semester)) {
        grouped[semester] = [];
      }
      grouped[semester]!.add(record);
    }
    // Sort keys
    final sortedKeys = grouped.keys.toList()..sort();
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  double getGPAForSemester(int semester) {
    final semesterRecords = _records
        .where((r) => (r.semester ?? 1) == semester)
        .toList();
    if (semesterRecords.isEmpty) return 0.0;

    double totalPoints = 0;
    double totalCreditHours = 0;

    for (var record in semesterRecords) {
      totalPoints += record.gradePointValue * record.creditHours;
      totalCreditHours += record.creditHours;
    }

    return totalCreditHours == 0 ? 0.0 : totalPoints / totalCreditHours;
  }

  Future<void> init() async {
    _box = await Hive.openBox<AcademicRecord>('academic_records');
    _records = _box!.values.toList();
    notifyListeners();
  }

  Future<void> addRecord(AcademicRecord record) async {
    if (_box == null) await init();
    await _box!.add(record);
    _records.add(record);
    notifyListeners();
  }

  Future<void> updateRecord(int index, AcademicRecord record) async {
    if (_box == null) await init();
    await _box!.putAt(index, record);
    _records[index] = record;
    notifyListeners();
  }

  Future<void> deleteRecord(int index) async {
    if (_box == null) await init();
    await _box!.deleteAt(index);
    _records.removeAt(index);
    notifyListeners();
  }

  Future<void> clearAllRecords() async {
    if (_box == null) await init();
    await _box!.clear();
    _records.clear();
    notifyListeners();
  }

  double calculateHypotheticalCGPA(List<AcademicRecord> hypotheticalRecords) {
    double totalPoints = 0;
    double totalCreditHours = 0;

    for (var record in hypotheticalRecords) {
      totalPoints += record.gradePointValue * record.creditHours;
      totalCreditHours += record.creditHours;
    }

    return totalCreditHours == 0 ? 0.0 : totalPoints / totalCreditHours;
  }
}
