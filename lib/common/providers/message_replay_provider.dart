import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/enums/message_enum.dart';

class MessageReplay {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReplay({
    required this.message,
    required this.isMe,
    required this.messageEnum,
  });
}

final messageReplayProvider = StateProvider<MessageReplay?>((ref) => null);
