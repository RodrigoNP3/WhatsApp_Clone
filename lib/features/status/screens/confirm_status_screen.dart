import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/colors.dart';
import 'package:whatsapp_flutter_ui/features/status/controller/status_controller.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String RouteName = '/confirm-status';
  final File file;

  ConfirmStatusScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  var wid = 16;
  var hei = 9;

  void aspectRatio() async {
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    wid = decodedImage.width;
    hei = decodedImage.height;
  }

  void addStatus(WidgetRef ref, BuildContext context) {
    ref
        .read(statusControllerProvider)
        .uploadStatus(statusImage: file, context: context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    aspectRatio();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: wid / hei,
          child: Image.file(
            file,
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tabColor,
        onPressed: () => addStatus(ref, context),
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
