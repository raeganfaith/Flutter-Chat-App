import 'package:chat_app/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = senderId == FirebaseAuth.instance.currentUser!.uid;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isCurrentUser ? AppColor.mainOrange : AppColor.silver,
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: isCurrentUser ? AppColor.white : AppColor.black,
        ),
      ),
    );
  }
}
