import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/conversation.dart';
import 'package:if_ride/services/chat_service.dart';
import 'package:if_ride/views/screens/chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _chatService = ChatService();
  List<Conversation> _conversations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final data = await _chatService.getConversations();
      setState(() => _conversations = data);
    } catch (_) {
      setState(() => _conversations = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, i) => _ConversationTile(
                      conversation: _conversations[i],
                    ),
                  ),
                ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id ?? '';
    final primaryColor = Theme.of(context).primaryColor;

    final isDriver = conversation.driverId == currentUserId;
    final otherName =
        isDriver ? conversation.passengerName : conversation.driverName;
    final otherId =
        isDriver ? conversation.passengerId : conversation.driverId;
    final roleLabel = isDriver ? 'Motorista' : 'Passageiro';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: primaryColor.withValues(alpha: 0.1),
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
          style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                  fontSize: 11,
                  color: primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          conversation.lastMessage ?? 'Conversa iniciada',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      onTap: () => Get.to(() => ChatScreen(
            rideId: conversation.rideId,
            recipientId: otherId,
            recipientName: otherName,
          )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma conversa ainda.\nQuando um motorista aceitar sua\nsolicitação, a conversa aparecerá aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
