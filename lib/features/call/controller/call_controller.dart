import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_flutter_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_flutter_ui/features/call/repository/call_repository.dart';

import 'package:whatsapp_flutter_ui/models/call_model.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
    callRepository: callRepository,
    ref: ref,
    auth: FirebaseAuth.instance,
  );
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;

  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(
    BuildContext context,
    String recieverName,
    String recieverUid,
    String recieverProfilePic,
    bool isGroupChat,
  ) async {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();

      CallModel senderCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        recieverId: recieverUid,
        recieverName: recieverName,
        recieverPic: recieverProfilePic,
        callId: callId,
        hasDialled: true,
      );
      CallModel recieverCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        recieverId: recieverUid,
        recieverName: recieverName,
        recieverPic: recieverProfilePic,
        callId: callId,
        hasDialled: false,
      );

      callRepository.mekeCall(context, senderCallData, recieverCallData);
    });
  }
}
