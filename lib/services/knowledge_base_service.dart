import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_gemini/data/chatbot_knowledge_base.dart';

class KnowledgeBaseService {
  static const String _csvPath = 'assets/data/Dataset UTP - Academic.csv';

  // Loads the knowledge base from the CSV file and combines it with the static data.
  Future<String> loadKnowledgeBase() async {
    try {
      // Load CSV file from assets
      final String csvString = await rootBundle.loadString(_csvPath);

      // Parse CSV data
      // Use CsvToListConverter with default settings (comma separator)
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
        eol: '\n',
      );

      if (csvTable.isEmpty) {
        return chatbotKnowledgeBase;
      }

      // Build the additional knowledge string
      StringBuffer buffer = StringBuffer();
      buffer.writeln('\n\n### ADDITIONAL KNOWLEDGE BASE (FROM CSV)');

      // Skip header row if it exists (assuming first row is header)
      int startIndex = 0;
      if (csvTable.isNotEmpty &&
          csvTable[0].isNotEmpty &&
          csvTable[0][0].toString().toLowerCase().contains('category')) {
        startIndex = 1;
      }

      // Iterate through rows
      String currentCategory = '';
      String currentSubCategory = '';

      for (int i = startIndex; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length < 4) continue; // Skip invalid rows

        final String category = row[0].toString().trim();
        final String subCategory = row[1].toString().trim();
        final String question = row[2].toString().trim();
        final String answer = row[3].toString().trim();

        if (category.isEmpty || question.isEmpty || answer.isEmpty) continue;

        // Add Category Header if changed
        if (category != currentCategory) {
          buffer.writeln('\n**$category**');
          currentCategory = category;
          currentSubCategory = ''; // Reset subcategory
        }

        // Add SubCategory Header if changed
        if (subCategory.isNotEmpty && subCategory != currentSubCategory) {
          buffer.writeln('- *$subCategory*');
          currentSubCategory = subCategory;
        }

        // Add Q&A
        buffer.writeln('  - Q: $question');
        buffer.writeln('    A: $answer');
      }

      // Combine static and dynamic knowledge
      return '$chatbotKnowledgeBase\n${buffer.toString()}';
    } catch (e) {
      // Fallback to static knowledge base if error occurs
      log('Error loading CSV knowledge base: $e');
      return chatbotKnowledgeBase;
    }
  }
}
