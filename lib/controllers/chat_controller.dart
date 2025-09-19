import 'dart:async';

import 'package:get/get.dart';
import 'package:if_ride/models/chat.dart';
import 'package:if_ride/models/chat_message.dart';
import 'package:if_ride/models/user.dart';

class ChatController extends GetxController {
  final Chat chat;

  ChatController(this.chat);

  var otherUserName = ''.obs;
  var messages = <ChatMessage>[].obs;
  var isLoadingMessages = false.obs;

  StreamSubscription<List<ChatMessage>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    fetchOtherUserName();
    loadMessages();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void loadMessages() async {
    
  }

  Future<Stream<List<ChatMessage>>?> messagesStream(Chat chat) async {
    
  }

  Future<ChatMessage?> save(String text, User user) async {
    
  }

  Future<void> fetchOtherUserName() async {
    
  }

  Future<User?> getOtherUser() async {
  
  }
}