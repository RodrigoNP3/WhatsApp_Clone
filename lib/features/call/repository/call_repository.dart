import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/models/call_model.dart';
import 'package:whatsapp_flutter_ui/models/group_model.dart';

import '../screens/call_screen.dart';

final callRepositoryProvider = Provider((ref) => CallRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ));

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => firestore
      .collection(Collections.call)
      .doc(auth.currentUser!.uid)
      .snapshots();

  void mekeCall(
    BuildContext context,
    CallModel senderCallData,
    CallModel recieverCallData,
  ) async {
    try {
      await firestore
          .collection(Collections.call)
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection(Collections.call)
          .doc(senderCallData.recieverId)
          .set(recieverCallData.toMap());

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
    BuildContext context,
    String callerId,
    String recieverId,
  ) async {
    try {
      await firestore.collection(Collections.call).doc(callerId).delete();
      await firestore.collection(Collections.call).doc(recieverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endGroupCall(
    BuildContext context,
    String callerId,
    String recieverId,
  ) async {
    try {
      await firestore.collection(Collections.call).doc(callerId).delete();

      var groupSnapshot =
          await firestore.collection(Collections.group).doc(recieverId).get();

      GroupModel group = GroupModel.fromMap(groupSnapshot.data()!);

      for (var id in group.membersUid) {
        await firestore.collection(Collections.call).doc(id).delete();
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void mekeGroupCall(
    BuildContext context,
    CallModel senderCallData,
    CallModel recieverCallData,
  ) async {
    try {
      await firestore
          .collection(Collections.call)
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await firestore
          .collection(Collections.group)
          .doc(senderCallData.recieverId)
          .get();

      GroupModel group = GroupModel.fromMap(groupSnapshot.data()!);

      for (var id in group.membersUid) {
        await firestore
            .collection(Collections.call)
            .doc(id)
            .set(recieverCallData.toMap());
      }

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: true,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
