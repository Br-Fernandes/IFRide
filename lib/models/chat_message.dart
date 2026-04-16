class ChatMessage {
  final String id;
  final String rideId;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String content;
  final String messageStatus;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.content,
    required this.messageStatus,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipientId: json['recipientId'] as String,
      content: json['content'] as String,
      messageStatus: json['messageStatus'] as String? ?? 'SENT',
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
