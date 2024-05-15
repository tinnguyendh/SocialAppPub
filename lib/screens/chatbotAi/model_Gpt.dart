
enum ChatMessageType { user, bot}
class ChatMessages {
  ChatMessages({
    required this.text,
    required this.chatMessageType,
  });

  final String text;
  final ChatMessageType chatMessageType;
}