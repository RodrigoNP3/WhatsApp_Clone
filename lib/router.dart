import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_flutter_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_flutter_ui/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_flutter_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_flutter_ui/features/landing/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_flutter_ui/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_flutter_ui/features/status/screens/status_screen.dart';
import 'package:whatsapp_flutter_ui/models/status_model.dart';

import 'common/widgets/error.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/chat/screens/mobile_chat_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  //
  switch (settings.name) {
    //
    case LoginScreen.RouteName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());

    case OTPScreen.RouteName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OTPScreen(
                verificationId: verificationId,
              ));

    case UserInformationScreen.RouteName:
      return MaterialPageRoute(
          builder: (context) => const UserInformationScreen());

    case MobileChatScreen.RouteName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final bool isGroupChat = arguments['isGroupChat'];
      final String profilePic = arguments['profilePic'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                name: name,
                uid: uid,
                isGroupChat: isGroupChat,
                profilePic: profilePic,
              ));

    case ConfirmStatusScreen.RouteName:
      final file = settings.arguments as File;

      return MaterialPageRoute(
          builder: (context) => ConfirmStatusScreen(
                file: file,
              ));
    case StatusScreen.RouteName:
      final status = settings.arguments as StatusModel;

      return MaterialPageRoute(
          builder: (context) => StatusScreen(status: status));

    case SelectContactsScreen.RouteName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen());

    case CreateGroupScreen.RouteName:
      return MaterialPageRoute(builder: (context) => const CreateGroupScreen());

    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorScreen(error: 'This page does not exist'),
              ));
  }
}
