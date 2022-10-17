import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_flutter_ui/common/enums/message_enum.dart';
import 'package:whatsapp_flutter_ui/common/repositories/common_firebase_storage.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';

import 'package:whatsapp_flutter_ui/models/chat_contact.dart';
import 'package:whatsapp_flutter_ui/models/group_model.dart';
import 'package:whatsapp_flutter_ui/models/message_model.dart';

import '../../../common/providers/message_replay_provider.dart';
import '../../../models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection(Collections.users)
        .doc(auth.currentUser!.uid)
        .collection(Collections.chats)
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContact> contacts = [];
        for (var document in event.docs) {
          var chatContact = ChatContact.fromMap(document.data());
          var userData = await firestore
              .collection(Collections.users)
              .doc(chatContact.contactId)
              .get();

          var user = UserModel.fromMap(userData.data()!);

          contacts.add(
            ChatContact(
              name: user.name,
              profilePic: user.profilePic,
              contactId: user.uid,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage,
            ),
          );
        }
        return contacts;
      },
    );
  }

  Stream<List<GroupModel>> getChatGroups() {
    return firestore.collection(Collections.group).snapshots().map(
      (event) {
        List<GroupModel> groups = [];
        for (var document in event.docs) {
          var group = GroupModel.fromMap(document.data());

          if (group.membersUid.contains(auth.currentUser!.uid)) {
            groups.add(group);
          }
        }
        return groups;
      },
    );
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection(Collections.users)
        .doc(auth.currentUser!.uid)
        .collection(Collections.chats)
        .doc(recieverUserId)
        .collection(Collections.messages)
        .orderBy('timeSent', descending: false)
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var documento in event.docs) {
          messages.add(Message.fromMap(documento.data()));
        }
        return messages;
      },
    );
  }

  Stream<List<Message>> getGroupStream(String groupId) {
    return firestore
        .collection(Collections.group)
        .doc(groupId)
        .collection(Collections.chats)
        .orderBy('timeSent', descending: false)
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var documento in event.docs) {
          messages.add(Message.fromMap(documento.data()));
        }
        return messages;
      },
    );
  }

  void _saveDataToContactsSubcollection({
    required UserModel senderUserData,
    required UserModel? recieverUserData,
    required String text,
    required DateTime timeSent,
    required String recieverUserId,
    required bool isGroupChat,
  }) async {
    var recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );

    if (isGroupChat) {
      await firestore.collection(Collections.group).doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await firestore
          .collection(Collections.users)
          .doc(recieverUserId)
          .collection(Collections.chats)
          .doc(auth.currentUser!.uid)
          .set(recieverChatContact.toMap());

      var senderChatContact = ChatContact(
        name: recieverChatContact.name,
        profilePic: recieverUserData!.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection(Collections.users)
          .doc(auth.currentUser!.uid)
          .collection(Collections.chats)
          .doc(recieverUserId)
          .set(senderChatContact.toMap());
    }
//
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String? recieverUsername,
    required MessageEnum messageType,
    required MessageReplay? messageReplay,
    required String senderUsername,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receaverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReplay == null ? '' : messageReplay.message,
      repliedMessageType:
          messageReplay == null ? MessageEnum.text : messageReplay.messageEnum,
      repliedTo: messageReplay == null
          ? ''
          : messageReplay.isMe
              ? senderUsername
              : recieverUsername ?? '',
    );

    if (isGroupChat) {
      await firestore
          .collection(Collections.group)
          .doc(recieverUserId)
          .collection(Collections.chats)
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection(Collections.users)
          .doc(auth.currentUser!.uid)
          .collection(Collections.chats)
          .doc(recieverUserId)
          .collection(Collections.messages)
          .doc(messageId)
          .set(message.toMap());

      await firestore
          .collection(Collections.users)
          .doc(recieverUserId)
          .collection(Collections.chats)
          .doc(auth.currentUser!.uid)
          .collection(Collections.messages)
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReplay? messageReplay,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      final messageId = const Uuid().v1();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap = await firestore
            .collection(Collections.users)
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      _saveDataToContactsSubcollection(
        senderUserData: senderUser,
        recieverUserData: recieverUserData,
        text: text,
        timeSent: timeSent,
        recieverUserId: recieverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        messageType: MessageEnum.text,
        messageReplay: messageReplay,
        senderUsername: senderUser.name,
        recieverUsername: recieverUserData?.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReplay? messageReplay,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file,
          );

      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap = await firestore
            .collection(Collections.users)
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📹 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubcollection(
        senderUserData: senderUserData,
        recieverUserData: recieverUserData,
        text: contactMsg,
        timeSent: timeSent,
        recieverUserId: recieverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        recieverUsername: recieverUserData?.name,
        messageType: messageEnum,
        messageReplay: messageReplay,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReplay? messageReplay,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      final messageId = const Uuid().v1();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap = await firestore
            .collection(Collections.users)
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      _saveDataToContactsSubcollection(
        senderUserData: senderUser,
        recieverUserData: recieverUserData,
        text: 'GIF',
        timeSent: timeSent,
        recieverUserId: recieverUserId,
        isGroupChat: isGroupChat,
      );

      _saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: gifUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUser.name,
          recieverUsername: recieverUserData?.name,
          messageType: MessageEnum.gif,
          messageReplay: messageReplay,
          senderUsername: senderUser.name,
          isGroupChat: isGroupChat);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(auth.currentUser!.uid)
          .collection(Collections.chats)
          .doc(recieverUserId)
          .collection(Collections.messages)
          .doc(messageId)
          .update({
        'isSeen': true,
      });
      await firestore
          .collection(Collections.users)
          .doc(recieverUserId)
          .collection(Collections.chats)
          .doc(auth.currentUser!.uid)
          .collection(Collections.messages)
          .doc(messageId)
          .update({
        'isSeen': true,
      });
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
