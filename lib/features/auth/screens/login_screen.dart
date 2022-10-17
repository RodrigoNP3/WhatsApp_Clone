import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/colors.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/common/widgets/custom_button.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:whatsapp_flutter_ui/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // ignore: constant_identifier_names
  static const RouteName = '/login-screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  Country? country;
  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
            // primaryColor: Colors.pink,
            ),
        child: CountryPickerDialog(
          divider: const Divider(),
          isDividerEnabled: true,
          itemBuilder: (Country _country) => Container(
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(5.0),
                child: Text('+${_country.phoneCode} ${_country.name}'),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(8.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: const InputDecoration(
            hintText: 'Search...',
            fillColor: backgroundColor,
            border: InputBorder.none,
          ),
          isSearchable: true,
          title: const Text('Select your country'),
          // ignore: no_leading_underscores_for_local_identifiers
          onValuePicked: (Country _country) {
            setState(() {
              country = _country;
            });
          },
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();

    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Faill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('WhatsApp will need to verify your number'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => pickCountry(context),
              child: const Text('Pick Country'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (country != null) Text('+${country!.phoneCode}'),
                const SizedBox(width: 10),
                SizedBox(
                  width: size.width * 0.7,
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: 'phone number',
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            SizedBox(
              width: 90,
              child: CustomButton(
                text: 'NEXT',
                onPressed: sendPhoneNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
