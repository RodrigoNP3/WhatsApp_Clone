import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/features/chat/screens/mobile_chat_screen.dart';

import '../../../../models/user_model.dart';

final selectContactRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({required this.firestore});

  List<Contact> registredContacts = [];

  List<Contact> getRegistredContacts() {
    return registredContacts;
  }

  Future<List<Contact>> getContatcts() async {
    //
    List<Contact> contacts = [];
    // List<Contact> registredContacts = [];
    try {
      //
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      for (var i = 0; i < contacts.length; i++) {
        var userDataFirebase = await firestore
            .collection(Collections.users)
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''),
            )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          registredContacts.add(contacts[i]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return registredContacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
//
    try {
//
      var userCollection = await firestore.collection(Collections.users).get();
      bool isFound = false;

      for (var document in userCollection.docs) {
//
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number
            .replaceAll(' ', '')
            .replaceAll('-', '');
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(context, MobileChatScreen.RouteName, arguments: {
            'name': userData.name,
            'uid': userData.uid,
            'profilePic': userData.profilePic,
          });
        }
      }
      if (!isFound) {
        showSnackBar(
            context: context,
            content: 'This number does not exist on this app');
      }
    } catch (e) {
//
      showSnackBar(context: context, content: e.toString());
    }
  }
}
