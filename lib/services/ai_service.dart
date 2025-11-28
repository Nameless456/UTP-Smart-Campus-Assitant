import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_gemini/config/secrets.dart';

import 'package:flutter_gemini/models/academic_record.dart';
import 'package:flutter_gemini/models/deadline_item.dart';
import 'package:flutter_gemini/data/academic_advice_data.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: Secrets.geminiApiKey,
    );
  }

  Future<String> getAcademicAdvice({
    required double currentCGPA,
    required double targetCGPA,
    required List<AcademicRecord> records,
    required List<DeadlineItem> deadlines,
  }) async {
    final prompt = StringBuffer();
    prompt.writeln(
      'You are an expert Academic Advisor at Universiti Teknologi PETRONAS (UTP).',
    );
    prompt.writeln(
      'Analyze the following student data and provide personalized advice.',
    );

    prompt.writeln('\n### ACADEMIC STATUS');
    prompt.writeln('Current CGPA: ${currentCGPA.toStringAsFixed(2)}');
    prompt.writeln('Target CGPA: ${targetCGPA.toStringAsFixed(2)}');

    // Inject Base Knowledge
    final baseAdvice = AcademicAdviceData.getBaseAdvice(currentCGPA);
    prompt.writeln('\n### BASE KNOWLEDGE (FOUNDATION)');
    prompt.writeln(baseAdvice);

    prompt.writeln('\n### COURSE RECORDS');
    if (records.isEmpty) {
      prompt.writeln('No course records available yet.');
    } else {
      for (var record in records) {
        prompt.writeln(
          '- ${record.courseCode}: ${record.creditHours} credits, Predicted Grade: ${record.predictedGrade}',
        );
      }
    }

    prompt.writeln('\n### UPCOMING DEADLINES');
    if (deadlines.isEmpty) {
      prompt.writeln('No upcoming deadlines.');
    } else {
      // Sort deadlines by weightage for the AI context
      final sortedDeadlines = List<DeadlineItem>.from(deadlines)
        ..sort((a, b) => b.weightage.compareTo(a.weightage));

      for (var item in sortedDeadlines) {
        prompt.writeln(
          '- ${item.title} (${item.courseCode}): Due ${item.dueDate.toString().split(' ')[0]}, Weightage: ${item.weightage}%',
        );
      }
    }

    prompt.writeln('\n### INSTRUCTIONS');
    prompt.writeln(
      '1. Use the "BASE KNOWLEDGE" as a foundation. Do not contradict it, but EXPAND on it.',
    );
    prompt.writeln(
      '2. Analyze if the Target CGPA is realistic based on current performance.',
    );
    prompt.writeln(
      '2. Provide specific study strategies for the courses listed, especially those with high credit hours.',
    );
    prompt.writeln(
      '3. Create a mini time-management plan based on the upcoming deadlines, prioritizing high-weightage tasks.',
    );
    prompt.writeln(
      '4. Keep the tone encouraging but realistic. Use emojis where appropriate.',
    );
    prompt.writeln('5. Format the response in Markdown.');

    try {
      final content = [Content.text(prompt.toString())];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to generate advice at this time.';
    } catch (e) {
      return 'Error generating advice: $e';
    }
  }
}
