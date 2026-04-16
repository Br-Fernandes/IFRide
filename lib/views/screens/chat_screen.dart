import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/controllers/chat_controller.dart';
import 'package:if_ride/controllers/new_message_controller.dart';
import 'package:if_ride/views/widgets/chat_widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String rideId;
  final String recipientId;
  final String recipientName;
  final bool mockMode;

  const ChatScreen({
    super.key,
    required this.rideId,
    required this.recipientId,
    required this.recipientName,
    this.mockMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(
      ChatController(
        rideId: rideId,
        recipientId: recipientId,
        recipientName: recipientName,
        mockMode: mockMode,
      ),
      tag: rideId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipientName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF53AC3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.delete<ChatController>(tag: rideId);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Obx(() => chatController.isConnected.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                )
              : const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.circle, color: Colors.grey, size: 12),
                )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final error = chatController.connectionError.value;
              if (error != null) {
                return Material(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Desconectado. Tentando reconectar...',
                            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(child: _MessagesList(rideId: rideId)),
            _NewMessage(rideId: rideId),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final String rideId;

  const _MessagesList({required this.rideId});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>(tag: rideId);
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (chatController.isLoadingMessages.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final msgs = chatController.messages;

      if (msgs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                'Nenhuma mensagem ainda.\nDiga olá!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      final currentUserId = authController.currentUser.value?.id;

      return ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: msgs.length,
        itemBuilder: (_, i) {
          final msg = msgs[msgs.length - 1 - i];
          return MessageBubble(
            message: msg,
            belongsToCurrentUser: msg.senderId == currentUserId,
          );
        },
      );
    });
  }
}

class _NewMessage extends StatelessWidget {
  final String rideId;

  const _NewMessage({required this.rideId});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>(tag: rideId);
    final controller = Get.put(NewMessageController(chatController));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              onChanged: (msg) => controller.message = msg,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Digite uma mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) {
                if (controller.message.trim().isNotEmpty) {
                  controller.sendMessage();
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Obx(() => CircleAvatar(
            backgroundColor: controller.message.trim().isEmpty
                ? Colors.grey.shade300
                : Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: controller.message.trim().isEmpty
                  ? null
                  : controller.sendMessage,
            ),
          )),
        ],
      ),
    );
  }
}
