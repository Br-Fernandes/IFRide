import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/chat_controller.dart';
import 'package:if_ride/models/chat.dart';
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/widgets/chat_widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController(chat), tag: chat.id);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
          Text(
            chatController.otherUserName.value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.delete<ChatController>(tag: chat.id);
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xFF53AC3C),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black87),
                      SizedBox(width: 10),
                      Text('Sair'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'logout') {
                  authController.logout();
                  Get.offAll(() => HomeScreen());
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _Messages(chat: chat)),
            _NewMessage(chat: chat),
          ],
        ),
      ),
    );
  }
}

class _Messages extends StatelessWidget {
  final Chat chat;

  _Messages({super.key, required this.chat});

  late ChatController controller;

  @override
  Widget build(BuildContext context) {
    controller = Get.put(ChatController(chat));  

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = controller.messages;

              if (messages.isEmpty) {
                return const Center(child: Text('Nenhuma mensagem ainda.'));
              }

              return ListView.builder(
                reverse: true, 
                itemCount: messages.length,
                itemBuilder: (ctx, i) {
                  final msg = messages[i];
                  return MessageBubble(
                    message: msg,
                    belongsToCurrentUser: messages[i].senderId == authController.currentUser.value!.id,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NewMessage extends StatelessWidget {
  final Chat chat;

  const _NewMessage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>(); 
    final controller = Get.put(NewMessageController(chatController)); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              onChanged: (msg) => controller.message = msg,
              decoration: const InputDecoration(
                labelText: 'Enviar mensagem...',
              ),
              onSubmitted: (_) {
                if (controller.message.trim().isNotEmpty) {
                  controller.sendMessage();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: controller.message.trim().isEmpty
                ? null
                : () => controller.sendMessage(),
          ),
        ],
      ),
    );
  }
}