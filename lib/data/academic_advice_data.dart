class AcademicAdviceData {
  static String getBaseAdvice(double cgpa) {
    if (cgpa >= 3.50) {
      return _firstClassAdvice;
    } else if (cgpa >= 3.00) {
      return _secondClassUpperAdvice;
    } else if (cgpa >= 2.50) {
      return _secondClassLowerAdvice;
    } else if (cgpa >= 2.00) {
      return _thirdClassAdvice;
    } else {
      return _probationAdvice;
    }
  }

  static const String _firstClassAdvice = '''
**Status:** First Class Standing (Excellent!)
**General Strategy:**
- Maintain your high standards but avoid burnout.
- Focus on deep understanding rather than just exam scoring.
- Start considering long-term goals like research, internships, or postgraduate studies.
- Mentor peers to reinforce your own understanding.
**Study Tips:**
- Use active recall and spaced repetition to retain information efficiently.
- Challenge yourself with advanced problems or supplementary materials.
''';

  static const String _secondClassUpperAdvice = '''
**Status:** Second Class Upper (Very Good)
**General Strategy:**
- You are doing well! Aim to bridge the gap to First Class.
- Identify specific subjects that pulled your average down and focus on them.
- Consistency is key; avoid last-minute cramming.
**Study Tips:**
- Review your past exam papers to understand where you lose marks.
- Form study groups with high-performing students.
- Improve your time management during exams.
''';

  static const String _secondClassLowerAdvice = '''
**Status:** Second Class Lower (Good)
**General Strategy:**
- You have a solid foundation, but there is room for significant improvement.
- Re-evaluate your study habits; current methods might be yielding average results.
- Prioritize coursework and attendance to secure easy marks.
**Study Tips:**
- Create a strict study schedule and stick to it.
- Seek help from lecturers or tutors early in the semester.
- Focus on understanding core concepts before moving to complex topics.
''';

  static const String _thirdClassAdvice = '''
**Status:** Third Class (Needs Improvement)
**General Strategy:**
- Immediate action is needed to improve your standing.
- Identify distractions and minimize them.
- Do not skip classes; attendance is crucial for catching up.
**Study Tips:**
- Focus on high-credit courses as they impact your CGPA the most.
- Use simple summaries and mind maps to grasp basics.
- Practice with past year papers repeatedly.
''';

  static const String _probationAdvice = '''
**Status:** Probation / Warning (Critical)
**General Strategy:**
- This is a critical time. You must prioritize your studies above all else.
- Consider reducing your course load if possible to focus on quality over quantity.
- Consult with your academic advisor immediately.
**Study Tips:**
- Attend every single class and sit in the front row.
- Complete all assignments on time, no matter how small.
- Find a study buddy who can keep you accountable.
''';
}
