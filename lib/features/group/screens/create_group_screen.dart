import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/utils/colors.dart';
import 'package:whatsapp_flutter_ui/features/group/controller/group_controller.dart';

import '../../../common/utils/utils.dart';

import '../widgets/select_contacs_group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  // ignore: constant_identifier_names
  static const String RouteName = '/create-group';
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController groupNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
            context,
            groupNameController.text.trim(),
            image!,
            ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.state).update((state) => []);
      Navigator.pop(context);
    }
  }

  void selectImage() async {
    image = await pickImageFromGalery(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        radius: 54,
                        backgroundImage: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQe-bvFbhIPYcLjKmcEIEmPNUydTr7nXxUnhg&usqp=CAU',
                        ),
                      )
                    : CircleAvatar(
                        radius: 54,
                        backgroundImage: FileImage(image!),
                      ),
                Positioned(
                  bottom: -10,
                  left: 70,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(hintText: 'Enter Group Name'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SelectContactsGroup(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
