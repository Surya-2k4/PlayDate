class ChatMessage {
  final String sender;
  final String text;
  final int timestamp;
  final String senderId;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.senderId = '',
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp,
    'senderId': senderId,
  };

  factory ChatMessage.fromMap(Map data) {
    return ChatMessage(
      sender: data['sender'] ?? 'Guest',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? 0,
      senderId: data['senderId'] ?? '',
    );
  }
}
