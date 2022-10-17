import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_flutter_ui/common/enums/message_enum.dart';
import 'package:whatsapp_flutter_ui/common/providers/message_replay_provider.dart';
import 'package:whatsapp_flutter_ui/common/widgets/loader.dart';
import 'package:whatsapp_flutter_ui/models/message_model.dart';

import './sender_message_card.dart';
import '../controller/chat_controller.dart';
import 'my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;

  ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplayProvider.state).update(
          (state) => MessageReplay(
            message: message,
            isMe: isMe,
            messageEnum: messageEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.recieverUserId)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            // messageController.initialScrollOffset.isFinite;
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];

              if (!messageData.isSeen &&
                  messageData.receaverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                      context,
                      widget.recieverUserId,
                      messageData.messageId,
                    );
              }

              if (messageData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: messageData.text,
                  date: DateFormat.Hm().format(messageData.timeSent),
                  type: messageData.type,
                  onLeftSwipe: () =>
                      onMessageSwipe(messageData.text, true, messageData.type),
                  replayMessageType: messageData.repliedMessageType,
                  replayText: messageData.repliedMessage,
                  username: messageData.repliedTo,
                  isSeen: messageData.isSeen,
                );
              } else {
                return SenderMessageCard(
                  message: messageData.text,
                  date: DateFormat.Hm().format(messageData.timeSent),
                  type: messageData.type,
                  onRightSwipe: () => onMessageSwipe(
                    messageData.text,
                    false,
                    messageData.type,
                  ),
                  replayMessageType: messageData.repliedMessageType,
                  replayText: messageData.repliedMessage,
                  username: messageData.repliedTo,
                );
              }
            },
          );
        });
  }
}

// class ChatList extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
   
//   }
// }
