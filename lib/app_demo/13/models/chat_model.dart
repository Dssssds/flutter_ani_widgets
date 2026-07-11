enum MessageSender {
  user,
  ai,
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime time;
  final MessageSender sender;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.sender,
  });
}
