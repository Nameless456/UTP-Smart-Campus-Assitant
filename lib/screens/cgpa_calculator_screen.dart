import 'package:flutter/material.dart';
import 'package:flutter_gemini/models/academic_record.dart';
import 'package:flutter_gemini/providers/academic_provider.dart';
import 'package:flutter_gemini/providers/deadline_provider.dart';
import 'package:flutter_gemini/services/ai_service.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _creditHoursController = TextEditingController();
  final _targetCgpaController = TextEditingController();

  int _selectedSemester = 1;
  String _selectedGrade = 'A';
  final Map<String, double> _gradeValues = {
    'A': 4.00,
    'A-': 3.75,
    'B+': 3.50,
    'B': 3.00,
    'C+': 2.50,
    'C': 2.00,
    'D+': 1.50,
    'D': 1.00,
    'F': 0.00,
  };

  String _aiAdvice = '';
  bool _isLoadingAdvice = false;

  @override
  void dispose() {
    _courseCodeController.dispose();
    _creditHoursController.dispose();
    _targetCgpaController.dispose();
    super.dispose();
  }

  void _addRecord() {
    if (_formKey.currentState!.validate()) {
      final record = AcademicRecord(
        courseCode: _courseCodeController.text,
        creditHours: double.parse(_creditHoursController.text),
        predictedGrade: _selectedGrade,
        gradePointValue: _gradeValues[_selectedGrade]!,
        semester: _selectedSemester,
      );

      Provider.of<AcademicProvider>(context, listen: false).addRecord(record);

      _courseCodeController.clear();
      _creditHoursController.clear();
      setState(() {
        _selectedGrade = 'A';
        // Keep selected semester for convenience
      });
      Navigator.pop(context);
    }
  }

  Future<void> _getAdvice() async {
    setState(() {
      _isLoadingAdvice = true;
      _aiAdvice = '';
    });

    final academicProvider = Provider.of<AcademicProvider>(
      context,
      listen: false,
    );
    final deadlineProvider = Provider.of<DeadlineProvider>(
      context,
      listen: false,
    );
    final targetCgpa = double.tryParse(_targetCgpaController.text) ?? 4.0;

    final advice = await AIService().getAcademicAdvice(
      currentCGPA: academicProvider.currentCGPA,
      targetCGPA: targetCgpa,
      records: academicProvider.records,
      deadlines: deadlineProvider.deadlines,
    );

    if (mounted) {
      setState(() {
        _aiAdvice = advice;
        _isLoadingAdvice = false;
      });
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course Record'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _creditHoursController,
                decoration: const InputDecoration(labelText: 'Credit Hours'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedSemester,
                items: List.generate(8, (index) => index + 1).map((sem) {
                  return DropdownMenuItem(
                    value: sem,
                    child: Text('Semester $sem'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSemester = value!),
                decoration: const InputDecoration(labelText: 'Semester'),
              ),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedGrade,
                items: _gradeValues.keys.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGrade = value!),
                decoration: const InputDecoration(labelText: 'Predicted Grade'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addRecord, child: const Text('Add')),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Are you sure you want to delete all academic records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AcademicProvider>(
                context,
                listen: false,
              ).clearAllRecords();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator & Advisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Data',
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CGPA Card
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Current CGPA',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          provider.currentCGPA.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Target CGPA Input
                TextField(
                  controller: _targetCgpaController,
                  decoration: InputDecoration(
                    labelText: 'Target CGPA',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      onPressed: _getAdvice,
                      tooltip: 'Get AI Advice',
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // AI Advice Section
                if (_isLoadingAdvice)
                  const Center(child: CircularProgressIndicator())
                else if (_aiAdvice.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Academic Advisor',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const Divider(),
                          MarkdownBody(data: _aiAdvice),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Course List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Course Records',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _showAddDialog,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),

                // Course List
                if (provider.records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No records added yet.')),
                  )
                else
                  ...provider.recordsBySemester.entries.map((entry) {
                    final semester = entry.key;
                    final records = entry.value;
                    final semesterGPA = provider.getGPAForSemester(semester);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Semester $semester'),
                        subtitle: Text(
                          'GPA: ${semesterGPA.toStringAsFixed(2)}',
                        ),
                        children: records.map((record) {
                          return Dismissible(
                            key: Key(record.key.toString()), // Use Hive key
                            onDismissed: (_) {
                              // Find index in main list to delete
                              final index = provider.records.indexOf(record);
                              provider.deleteRecord(index);
                            },
                            background: Container(color: Colors.red),
                            child: ListTile(
                              title: Text(record.courseCode),
                              subtitle: Text('${record.creditHours} Credits'),
                              trailing: CircleAvatar(
                                child: Text(record.predictedGrade),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
