import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/features/landing/select_contacts/repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(selectContactRepositoryProvider);
  return selectContactRepository.getContatcts();
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;
  SelectContactController({
    required this.ref,
    required this.selectContactRepository,
  });

  final selectContactControllerProvider = Provider((ref) {
    final selectContactRepository = ref.watch(selectContactRepositoryProvider);
    return SelectContactController(
        ref: ref, selectContactRepository: selectContactRepository);
  });

  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactRepository.selectContact(selectedContact, context);
  }

  List<Contact>? getRegistredContacts() {
    selectContactRepository.registredContacts;
  }
}
