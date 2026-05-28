class Conversation {
  final String id;
  final String rideId;
  final String driverId;
  final String driverName;
  final String passengerId;
  final String passengerName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.passengerId,
    required this.passengerName,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
