class ChatMessage {
  final int id;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMine; // O campo que o backend manda

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isMine: json['isMine'],
    );
  }
}