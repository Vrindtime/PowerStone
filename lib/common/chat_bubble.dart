import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String time;
  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container( 
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Flexible(
        child: Text(
          message,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
