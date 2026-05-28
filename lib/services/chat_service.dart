import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/chat_message.dart';
import 'package:if_ride/models/conversation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
class ChatService {
  static const _baseUrl = 'http://10.0.2.2:8080';
  static const _wsUrl = 'ws://10.0.2.2:8080/ws';

  static const _ghostId = 'ghost-user-001';
  static const _ghostName = 'Usuário Fantasma';
  static const _mockCurrentUserId = 'mock-id-123';

  static const _ghostReplies = [
    'Olá! Sou o usuário fantasma 👻',
    'Recebi sua mensagem!',
    'Tudo funcionando por aqui.',
    'Backend e frontend conectados com sucesso!',
    'Pode testar à vontade.',
    'WebSocket operacional!',
  ];
  int _replyIndex = 0;

  final bool mockMode;
  void Function(ChatMessage)? _mockOnMessage;

  ChatService({this.mockMode = false});

  final _storage = const FlutterSecureStorage();
  StompClient? _stompClient;

  Future<String?> _getToken() => _storage.read(key: 'jwt_token');

  /// Conecta ao WebSocket e inscreve no tópico da viagem.
  Future<void> connect({
    required String rideId,
    required void Function(ChatMessage message) onMessage,
    required void Function() onConnected,
    required void Function(String error) onError,
  }) async {
    if (mockMode) {
      _mockOnMessage = onMessage;
      Future.delayed(const Duration(milliseconds: 500), () {
        onConnected();
        Future.delayed(const Duration(seconds: 1), () {
          onMessage(_mockMessage(rideId, 'Olá! Sou o usuário fantasma 👻'));
        });
      });
      return;
    }

    final token = await _getToken();
    if (token == null) {
      onError('Token não encontrado. Faça login novamente.');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        // Token enviado como query param — lido pelo JwtHandshakeInterceptor
        url: '$_wsUrl?token=$token',
        onConnect: (frame) {
          onConnected();
          _stompClient!.subscribe(
            destination: '/topic/rides/$rideId/messages',
            callback: (frame) {
              if (frame.body != null) {
                try {
                  final json = jsonDecode(frame.body!) as Map<String, dynamic>;
                  onMessage(ChatMessage.fromJson(json));
                } catch (_) {}
              }
            },
          );
        },
        onStompError: (frame) => onError(frame.body ?? 'Erro STOMP'),
        onWebSocketError: (error) => onError(error.toString()),
        onDisconnect: (_) {},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _stompClient!.activate();
  }

  /// Envia mensagem via STOMP → /app/chat.send
  void sendMessage({
    required String rideId,
    required String recipientId,
    required String content,
  }) {
    if (mockMode) {
      // Ecoa a mensagem do usuário atual e depois responde como fantasma
      Future.delayed(const Duration(milliseconds: 800), () {
        final reply = _ghostReplies[_replyIndex % _ghostReplies.length];
        _replyIndex++;
        _mockOnMessage?.call(_mockMessage(rideId, reply));
      });
      return;
    }

    _stompClient?.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'rideId': rideId,
        'recipientId': recipientId,
        'content': content,
      }),
    );
  }

  ChatMessage _mockMessage(String rideId, String content) {
    return ChatMessage(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      rideId: rideId,
      senderId: _ghostId,
      senderName: _ghostName,
      recipientId: _mockCurrentUserId,
      content: content,
      messageStatus: 'SENT',
      timestamp: DateTime.now(),
    );
  }

  /// Busca conversas do usuário logado
  Future<List<Conversation>> getConversations() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/v1/chat/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Busca histórico de mensagens da viagem via REST
  Future<List<ChatMessage>> getHistory(String rideId) async {
    if (mockMode) {
      return [
        ChatMessage(
          id: 'hist-1',
          rideId: rideId,
          senderId: _ghostId,
          senderName: _ghostName,
          recipientId: _mockCurrentUserId,
          content: 'Histórico: primeira mensagem de teste.',
          messageStatus: 'READ',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        ChatMessage(
          id: 'hist-2',
          rideId: rideId,
          senderId: _mockCurrentUserId,
          senderName: 'Eu',
          recipientId: _ghostId,
          content: 'Histórico: minha resposta.',
          messageStatus: 'READ',
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        ),
      ];
    }

    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/v1/chat/messages/$rideId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Marca mensagem como lida
  Future<void> markAsRead(String messageId) async {
    final token = await _getToken();
    if (token == null) return;
    await http.put(
      Uri.parse('$_baseUrl/v1/chat/messages/$messageId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
