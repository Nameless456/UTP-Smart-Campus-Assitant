import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/widgets/bottom_chat_field.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ChatScreen> {
  // controler for the input field
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement ==
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child){
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text(' UTP Smart Campus Assistant '),
          ), 
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child:chatProvider.inChatMessages.isEmpty
                    ? const Center(
                      child: Text('No messages yet. Start the conversation!'),
                    )
                    :
                    
                    
                     ListView.builder(
                      itemCount: chatProvider.inChatMessages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.inChatMessages[index];
                        return ListTile(
                          title: Text(message.message.toString()),
                        );
                      },
                    ),
                  ),

                  // input field
                  BottomChatField(chatProvider: chatProvider,)
                ],
              ),
            ),
          ),
        );
      } ,
    );
  }
}