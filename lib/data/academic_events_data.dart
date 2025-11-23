import 'package:flutter_gemini/models/academic_event.dart';
import 'package:uuid/uuid.dart';

class AcademicEventsData {
  static List<AcademicEvent> getEvents() {
    final now = DateTime.now();

    return [
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Mid-Semester Examination',
        description: 'Mid-semester exams for all courses',
        date: DateTime(now.year, now.month, now.day + 7),
        category: 'Exam',
        icon: '📝',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Course Registration',
        description: 'Registration period for next semester courses',
        date: DateTime(now.year, now.month, now.day + 14),
        category: 'Registration',
        icon: '📋',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Final Examination',
        description: 'Final exams for all courses',
        date: DateTime(now.year, now.month + 2, now.day),
        category: 'Exam',
        icon: '📚',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Semester Break',
        description: 'Mid-semester break - No classes',
        date: DateTime(now.year, now.month, now.day + 21),
        category: 'Holiday',
        icon: '🏖️',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Career Fair',
        description: 'Annual UTP Career Fair - Meet potential employers',
        date: DateTime(now.year, now.month + 1, now.day),
        category: 'Event',
        icon: '💼',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Sports Day',
        description: 'UTP Annual Sports Day',
        date: DateTime(now.year, now.month, now.day + 30),
        category: 'Event',
        icon: '⚽',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Assignment Deadline',
        description: 'Programming assignment submission deadline',
        date: DateTime(now.year, now.month, now.day + 3),
        category: 'Deadline',
        icon: '⏰',
      ),
      AcademicEvent(
        id: const Uuid().v4(),
        title: 'Graduation Ceremony',
        description: 'Convocation ceremony for graduating students',
        date: DateTime(now.year, now.month + 3, 15),
        category: 'Event',
        icon: '🎓',
      ),
    ];
  }

  // Get upcoming events (not past)
  static List<AcademicEvent> getUpcomingEvents() {
    return getEvents().where((event) => !event.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get events by category
  static List<AcademicEvent> getEventsByCategory(String category) {
    return getEvents()
        .where((event) => event.category == category && !event.isPast)
        .toList();
  }
}
