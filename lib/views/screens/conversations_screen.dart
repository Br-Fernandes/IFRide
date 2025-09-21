import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/chat_controller.dart';
import 'package:if_ride/controllers/new_message_controller.dart';
import 'package:if_ride/models/chat.dart';
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/widgets/chat_widgets/message_bubble.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Suas Conversas",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}