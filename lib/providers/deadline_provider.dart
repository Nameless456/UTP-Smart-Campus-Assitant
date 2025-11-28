import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gemini/models/deadline_item.dart';

class DeadlineProvider extends ChangeNotifier {
  List<DeadlineItem> _deadlines = [];
  Box<DeadlineItem>? _box;

  List<DeadlineItem> get deadlines {
    // Sort by urgency (soonest first) AND weightage (highest first)

    final sortedList = List<DeadlineItem>.from(_deadlines);
    sortedList.sort((a, b) {
      // First compare by due date
      int dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) {
        return dateComparison;
      }
      // If due dates are same, compare by weightage (descending)
      return b.weightage.compareTo(a.weightage);
    });
    return sortedList;
  }

  Future<void> init() async {
    _box = await Hive.openBox<DeadlineItem>('deadlines');
    _deadlines = _box!.values.toList();
    notifyListeners();
  }

  Future<void> addDeadline(DeadlineItem item) async {
    if (_box == null) await init();
    await _box!.add(item);
    _deadlines.add(item);
    notifyListeners();
  }

  Future<void> toggleCompletion(int index, bool? value) async {
    if (_box == null) await init();
  }

  Future<void> toggleCompletionByItem(DeadlineItem item) async {
    item.isCompleted = !item.isCompleted;
    await item.save(); // HiveObject method
    notifyListeners();
  }

  Future<void> deleteDeadline(DeadlineItem item) async {
    await item.delete(); // HiveObject method
    _deadlines.remove(item);
    notifyListeners();
  }

  Future<void> clearAllDeadlines() async {
    if (_box == null) await init();
    await _box!.clear();
    _deadlines.clear();
    notifyListeners();
  }
}
