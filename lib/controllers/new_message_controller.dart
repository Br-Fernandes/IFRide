import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/chat_controller.dart';
import 'package:if_ride/utils/constants.dart';

class NewMessageController extends GetxController {
  final ChatController chatController;

  NewMessageController(this.chatController);

  final _message = ''.obs;
  final _messageController = TextEditingController();

  String get message => _message.value;
  set message (String msg) => _message.value = msg; 

  TextEditingController get messageController => _messageController;

  Future<void> sendMessage() async {
   if (_message.value.trim().isNotEmpty) {
      final user = authController.currentUser;
      await chatController.save(_message.value, user.value!); 
      _messageController.clear();
      _message.value = '';
    }
  }
}