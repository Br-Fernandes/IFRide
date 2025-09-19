class Chat {
  final String id;
  final List<String> usersId;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;

  Chat({
    required this.id,
    required this.usersId,
    this.lastMessage,
    this.lastMessageTimestamp
  });

}