import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/enums/message_enum.dart';
import 'package:whatsapp_flutter_ui/common/providers/message_replay_provider.dart';
import 'package:whatsapp_flutter_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_flutter_ui/features/chat/repository/chat_repository.dart';
import 'package:whatsapp_flutter_ui/models/chat_contact.dart';
import 'package:whatsapp_flutter_ui/models/group_model.dart';
import 'package:whatsapp_flutter_ui/models/message_model.dart';

final chatControllerProvider = Provider(
  (ref) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return CharController(chatRepository: chatRepository, ref: ref);
  },
);

class CharController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  CharController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<GroupModel>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }

  Stream<List<Message>> groupChatStream(String recieverUserId) {
    return chatRepository.getGroupStream(recieverUserId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
    bool isGroupChat,
  ) {
    final messageReplay = ref.read(messageReplayProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReplay: messageReplay,
            isGroupChat: isGroupChat,
          ),
        );
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String recieverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    final messageReplay = ref.read(messageReplayProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            recieverUserId: recieverUserId,
            file: file,
            messageEnum: messageEnum,
            senderUserData: value!,
            ref: ref,
            messageReplay: messageReplay,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplayProvider.state).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String recieverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    //https://i.giphy.com/media/${...}/200.git

    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPartIndex/200.gif';
    final messageReplay = ref.read(messageReplayProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newGifUrl,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReplay: messageReplay,
            isGroupChat: isGroupChat,
          ),
        );
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,

    // bool isGroupChat,
  ) {
    chatRepository.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }
}
