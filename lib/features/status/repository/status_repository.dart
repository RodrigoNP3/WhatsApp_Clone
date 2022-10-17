import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_flutter_ui/common/repositories/common_firebase_storage.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/models/status_model.dart';
import 'package:whatsapp_flutter_ui/models/user_model.dart';

final statusRepositoryProvider = Provider((ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      List<Contact> contacts = [];

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      List<String> uidWhoCanSee = [];

      for (var i = 0; i < contacts.length; i++) {
        var userDataFirebase = await firestore
            .collection(Collections.users)
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''),
            )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
      }

      List<String> statusImageUrls = [];

      var statusSnapshot = await firestore
          .collection(Collections.status)
          .where('uid', isEqualTo: auth.currentUser!.uid)
          // .where('createdAt',
          //     isLessThan: DateTime.now().subtract(const Duration(hours: 24)))
          .get();

      if (statusSnapshot.docs.isNotEmpty) {
        StatusModel status = StatusModel.fromMap(statusSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);

        await firestore
            .collection(Collections.status)
            .doc(statusSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [];
        statusImageUrls.add(imageUrl);
      }

      StatusModel status = StatusModel(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );
      await firestore
          .collection(Collections.status)
          .doc(statusId)
          .set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    print('11111111');
    List<StatusModel> statusData = [];
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      print('22222222');

      for (var i = 0; i < contacts.length; i++) {
        var statusSnapshot = await firestore
            .collection(Collections.status)
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''),
            )
            .where('createdAt',
                isGreaterThan: DateTime.now()
                    .subtract(const Duration(hours: 24))
                    .millisecondsSinceEpoch)
            .get();
        if (statusSnapshot.docs.isEmpty) {
          print('ESTA VAZIO');
        } else if (statusSnapshot.docs.isNotEmpty) {
          print('NÃO ESTA VAZIO');
        }
        for (var tempData in statusSnapshot.docs) {
          print('333333333');
          var tempStatus = StatusModel.fromMap(tempData.data());
          // print(tempStatus.username);
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
            print('4444444');
            // print(tempStatus.username);
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    print(statusData);
    return statusData;
  }
}
