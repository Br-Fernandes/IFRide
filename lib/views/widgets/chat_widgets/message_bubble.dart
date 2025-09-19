import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool belongsToCurrentUser;

  const MessageBubble({
    required this.message,
    required this.belongsToCurrentUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(MessageBubbleController());

    return Stack(
      children: [
        Align(
          alignment: belongsToCurrentUser ? Alignment.topRight : Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: belongsToCurrentUser ? Colors.grey.shade300 : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: belongsToCurrentUser ? const Radius.circular(12) : Radius.zero,
                bottomRight: belongsToCurrentUser ? Radius.zero : const Radius.circular(12),
              ),
            ),
            width: 180,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
            child: Column(
              crossAxisAlignment: belongsToCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  belongsToCurrentUser ? "Você" : "abrobra",
                  style: TextStyle(
                    color: belongsToCurrentUser ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  message.text,
                  textAlign: belongsToCurrentUser ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: belongsToCurrentUser ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Positioned(
        //   top: 0,
        //   left: belongsToCurrentUser ? null : 165,
        //   right: belongsToCurrentUser ? 165 : null,
        //   child: CircleAvatar(
        //     backgroundImage: getUserImage(message.image)
        //   ),
        // ),
      ],
    );
  }

  ImageProvider getUserImage(String imageUrl) {
    const String _defaultImage = 'assets/images/avatar.png';

    final uri = Uri.parse(imageUrl);

    if (uri.path.contains(_defaultImage)) {
      return const AssetImage(_defaultImage);
    } else if (uri.scheme.contains('http')) {
      return NetworkImage(uri.toString());
    } else {
      return FileImage(File(uri.toString()));
    }
  }
}