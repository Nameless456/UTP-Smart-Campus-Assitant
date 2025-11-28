import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';

class QuickReplyChips extends StatelessWidget {
  final ChatProvider chatProvider;
  final bool useWrap;

  const QuickReplyChips({
    super.key,
    required this.chatProvider,
    this.useWrap = false,
  });

  final List<String> _defaultReplies = const [
    "Bus Schedule 🚌",
    "Library Hours 📚",
    "Exam Dates 📅",
    "Cafeteria Menu 🍔",
    "Campus Map 🗺️",
    "Clinic Info 🏥",
  ];

  @override
  Widget build(BuildContext context) {
    final replies = chatProvider.suggestedReplies.isNotEmpty
        ? chatProvider.suggestedReplies
        : _defaultReplies;

    if (useWrap) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: replies.map((reply) => _buildChip(context, reply)).toList(),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: replies.length,
        itemBuilder: (context, index) {
          final reply = replies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildChip(context, reply),
          );
        },
      ),
    );
  }

  Widget _buildChip(BuildContext context, String reply) {
    return ActionChip(
      label: Text(reply),
      onPressed: () {
        chatProvider.sentMessage(
          message: reply,
          isTextOnly: true,
          context: context,
        );
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
