import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/features/auth/controller/auth_controller.dart';

import '../../../common/utils/colors.dart';

class OTPScreen extends ConsumerWidget {
  final String verificationId;
  // ignore: constant_identifier_names
  static const String RouteName = '/otp-screen';

  const OTPScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(authControllerProvider)
        .vefiryOTP(context, verificationId, userOTP);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying your number'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                        'We have sent an SMS with your verification code'),
                    SizedBox(
                      width: size.width * 0.5,
                      child: TextField(
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '- - - - - -',
                          hintStyle: TextStyle(fontSize: 30),
                        ),
                        onChanged: (val) {
                          //
                          if (val.length == 6) {
                            verifyOTP(ref, context, val.trim());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
