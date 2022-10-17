import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/widgets/error.dart';
import 'package:whatsapp_flutter_ui/common/widgets/loader.dart';
import 'package:whatsapp_flutter_ui/features/landing/select_contacts/controller/select_contact_controller.dart';
import '../controller/select_contact_controller.dart';
import '../repository/select_contact_repository.dart';

class SelectContactsScreen extends ConsumerWidget {
  // ignore: constant_identifier_names
  static const String RouteName = '/select-contact';

  const SelectContactsScreen({Key? key}) : super(key: key);

  void selectContact(
      // ignore: no_leading_underscores_for_local_identifiers
      WidgetRef _ref,
      Contact selectedContact,
      BuildContext context) {
    _ref.read(
      Provider(
        (ref) {
          final selectContactRepository =
              ref.watch(selectContactRepositoryProvider);
          return SelectContactController(
              ref: ref, selectContactRepository: selectContactRepository);
        },
      ),
    ).selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search),
        //   ),
        // ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) => ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return InkWell(
                  onTap: () {
                    // print(contact.phones);
                    selectContact(ref, contact, context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                        title: Text(
                          contact.displayName,
                          style: const TextStyle(fontSize: 18),
                        ),
                        // subtitle: Text(contact.),
                        leading: contact.photo != null
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.photo!),
                                radius: 20,
                              )
                            : const CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.person),
                              )),
                  ),
                );
              },
            ),
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
