import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/repositories/common_firebase_storage.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/models/user_model.dart';
import 'package:whatsapp_flutter_ui/mobile_layout_screen.dart';

import '../screens/otp_screen.dart';
import '../screens/user_information_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserModel?> getCurrentUserData() async {
    var userData = await firestore
        .collection(Collections.users)
        .doc(auth.currentUser?.uid)
        .get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    //
    try {
      //
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message!);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Navigator.pushNamed(context, OTPScreen.RouteName,
              arguments: verificationId);
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      //
      showSnackBar(context: context, content: e.message!);
    }
  }

  void vefiryOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    //
    try {
      //
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );

      await auth.signInWithCredential(credential);

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInformationScreen.RouteName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      //
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    //
    try {
      //
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQe-bvFbhIPYcLjKmcEIEmPNUydTr7nXxUnhg&usqp=CAU';
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase('profilePic/$uid', profilePic);
      }
      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        isOnline: false,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
      );
      await firestore.collection(Collections.users).doc(uid).set(user.toMap());

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (route) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      //
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return firestore
        .collection(Collections.users)
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await firestore
        .collection(Collections.users)
        .doc(auth.currentUser!.uid)
        .update({'isOnline': isOnline});
  }
}
