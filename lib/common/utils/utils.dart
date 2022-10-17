import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//API KEYS

class AppConstants {
  static final List<String> values = [
    GIPHY_API_KEY,
    baseUrl,
  ];
  // ignore: non_constant_identifier_names
  static String GIPHY_API_KEY = 'YOUR GIPHY API KEY HERE';
  static String baseUrl =
      'YOUR HEROKU BASE URL HERE WITHOUT THE SLASH AT THE END';
}

showSnackBar({required BuildContext context, required String content}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Future<File?> pickImageFromGalery(BuildContext context) async {
  //
  File? image;
  try {
    //
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    //
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGalery(BuildContext context) async {
  //
  File? video;
  try {
    //
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    //
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

class Collections {
  static final List<String> values = [
    users,
    chats,
    messages,
    status,
    group,
    call,
  ];
  static String users = 'users';
  static String chats = 'chats';
  static String messages = 'messages';
  static String status = 'status';
  static String group = 'group';
  static String call = 'call';
}

// ignore: body_might_complete_normally_nullable
Future<GiphyGif?> pickGIF(BuildContext context) async {
  // ignore: unused_local_variable
  GiphyGif? gif;
  try {
    return gif = await Giphy.getGif(
      context: context,
      apiKey: AppConstants.GIPHY_API_KEY,
    );
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
}
