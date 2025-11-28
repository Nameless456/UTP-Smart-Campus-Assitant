import 'package:flutter/material.dart';
import 'package:flutter_gemini/models/deadline_item.dart';
import 'package:flutter_gemini/providers/deadline_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DeadlineTrackerScreen extends StatefulWidget {
  const DeadlineTrackerScreen({super.key});

  @override
  State<DeadlineTrackerScreen> createState() => _DeadlineTrackerScreenState();
}

class _DeadlineTrackerScreenState extends State<DeadlineTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _weightageController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _courseCodeController.dispose();
    _weightageController.dispose();
    super.dispose();
  }

  void _addDeadline() {
    if (_formKey.currentState!.validate()) {
      final deadline = DeadlineItem(
        title: _titleController.text,
        courseCode: _courseCodeController.text,
        dueDate: _selectedDate,
        weightage: double.parse(_weightageController.text),
      );

      Provider.of<DeadlineProvider>(
        context,
        listen: false,
      ).addDeadline(deadline);

      _titleController.clear();
      _courseCodeController.clear();
      _weightageController.clear();
      setState(() {
        _selectedDate = DateTime.now().add(const Duration(days: 1));
      });
      Navigator.pop(context);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Deadline'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (e.g. Assignment 1)',
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _courseCodeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _weightageController,
                  decoration: const InputDecoration(labelText: 'Weightage (%)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Due Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDate = picked);
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(onPressed: _addDeadline, child: const Text('Add')),
          ],
        ),
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Are you sure you want to delete all deadlines? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DeadlineProvider>(
                context,
                listen: false,
              ).clearAllDeadlines();
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
        title: const Text('Deadline Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Data',
            onPressed: _confirmReset,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<DeadlineProvider>(
        builder: (context, provider, child) {
          if (provider.deadlines.isEmpty) {
            return const Center(child: Text('No upcoming deadlines.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.deadlines.length,
            itemBuilder: (context, index) {
              final deadline = provider.deadlines[index];
              final daysLeft = deadline.dueDate
                  .difference(DateTime.now())
                  .inDays;
              final isUrgent = daysLeft <= 7 && !deadline.isCompleted;

              return Card(
                elevation: isUrgent ? 4 : 1,
                shape: RoundedRectangleBorder(
                  side: isUrgent
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 2,
                        )
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: deadline.isCompleted,
                    onChanged: (value) {
                      provider.toggleCompletionByItem(deadline);
                    },
                  ),
                  title: Text(
                    deadline.title,
                    style: TextStyle(
                      decoration: deadline.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${deadline.courseCode} • ${deadline.weightage}% Weightage',
                      ),
                      Text(
                        'Due: ${DateFormat('dd MMM yyyy').format(deadline.dueDate)} ($daysLeft days left)',
                        style: TextStyle(
                          color: isUrgent
                              ? Theme.of(context).colorScheme.error
                              : null,
                          fontWeight: isUrgent ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.deleteDeadline(deadline),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
