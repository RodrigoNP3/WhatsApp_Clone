import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/models/call_model.dart';

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
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
