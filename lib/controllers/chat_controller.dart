import 'package:get/get.dart';
import 'package:if_ride/models/chat_message.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/services/chat_service.dart';

class ChatController extends GetxController {
  final String rideId;
  final String recipientId;
  final String recipientName;

  final bool mockMode;

  ChatController({
    required this.rideId,
    required this.recipientId,
    required this.recipientName,
    this.mockMode = false,
  });

  late final _chatService = ChatService(mockMode: mockMode);

  final messages = <ChatMessage>[].obs;
  final isLoadingMessages = false.obs;
  final isConnected = false.obs;
  final connectionError = RxnString();

  // Mantido para compatibilidade com ChatScreen
  RxString get otherUserName => recipientName.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
    _connectWebSocket();
  }

  @override
  void onClose() {
    _chatService.disconnect();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    isLoadingMessages.value = true;
    try {
      final history = await _chatService.getHistory(rideId);
      messages.assignAll(history);
    } catch (_) {
      // histórico vazio não é erro crítico
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void _connectWebSocket() {
    _chatService.connect(
      rideId: rideId,
      onMessage: (msg) {
        // Evita duplicar mensagem que já veio do histórico
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
        }
      },
      onConnected: () => isConnected.value = true,
      onError: (error) {
        isConnected.value = false;
        connectionError.value = error;
      },
    );
  }

  /// Chamado por NewMessageController
  Future<void> save(String text, User user) async {
    if (text.trim().isEmpty) return;
    _chatService.sendMessage(
      rideId: rideId,
      recipientId: recipientId,
      content: text.trim(),
    );
  }
}
