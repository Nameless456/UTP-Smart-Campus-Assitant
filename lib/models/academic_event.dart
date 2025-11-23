class AcademicEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String icon;

  AcademicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.icon,
  });

  // Calculate days until event
  int get daysUntil {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }

  // Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if event is in the past
  bool get isPast {
    return date.isBefore(DateTime.now());
  }
}
