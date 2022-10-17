import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/widgets/error.dart';
import 'package:whatsapp_flutter_ui/common/widgets/loader.dart';
import 'package:whatsapp_flutter_ui/features/landing/select_contacts/controller/select_contact_controller.dart';

final selectedGroupContacts = StateProvider<List<Contact>>(((ref) => []));

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
  List<Contact> selectedContacts = [];

  void selectContact(int index, Contact contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.removeWhere(
        (element) => element.id == contact.id,
      );
    } else {
      selectedContacts.add(contact);
    }
    setState(() {
      ref.read(selectedGroupContacts.state).update((state) => selectedContacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
          data: (contactsList) => Expanded(
            child: ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                final contact = contactsList[index];
                print(selectedContacts);
                return InkWell(
                  onTap: () => selectContact(index, contact),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: selectedContacts.contains(contact)
                          ? IconButton(
                              onPressed: () {}, icon: const Icon(Icons.done))
                          : null,
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          error: (err, trace) => ErrorScreen(error: err.toString()),
          loading: () => const Loader(),
        );
  }
}
