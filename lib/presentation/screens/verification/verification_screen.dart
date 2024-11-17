import 'package:flutter/material.dart';

import '../../../utils/styles/themes.dart';
import '../../widgets/auth/auth_body.dart';
import '../../widgets/auth/auth_elevated_button.dart';
import '../../widgets/auth/auth_header_image.dart';
import '../../widgets/auth/auth_text_form_field.dart';
import '../../widgets/forgot_password/linear_gradient_title.dart';
import '../../widgets/forgot_password/message_content.dart';
import '../../widgets/forgot_password/stacks_bottom.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final TextEditingController _codeController;

  late ValueNotifier<bool> _isLoading;

  @override
  void initState() {
    _codeController = TextEditingController();
    _isLoading = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          const AuthHeaderImage(
            height: 0.36,
            childAspectRatio: 1.85,
          ),
          AuthBody(
            marginTop: MediaQuery.of(context).size.height * 0.26,
            height: double.infinity,
            column: Column(
              children: [
                LinearGradientTitle(
                  text: "VERIFICATION",
                  textStyle: AppTheme.forgotPasswordLabelStyle,
                ),
                const SizedBox(
                  height: 15,
                ),
                const MessageContent(
                    text:
                        "A message with verification code was sent to your email."),
                const SizedBox(
                  height: 30,
                ),
                AuthTextFormField(
                    textEditingController: _codeController,
                    hintText: "Type verification code"),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Don't receive the code".toUpperCase(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const AuthElevatedButton(
                  width: double.infinity,
                  height: 52,
                  inputText: "VERIFY",
                  isLoading: false,
                ),
                const SizedBox(
                  height: 20,
                ),
                const StacksBottom(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
