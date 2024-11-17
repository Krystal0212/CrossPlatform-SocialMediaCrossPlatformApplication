import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/forgot_pasword/cubit/forgot_password_cubit.dart';
import 'package:socialapp/presentation/screens/forgot_pasword/cubit/forgot_password_state.dart';
import 'package:socialapp/utils/styles/themes.dart';

import '../../../utils/mixin/validators/validators.dart';
import '../../widgets/auth/auth_body.dart';
import '../../widgets/auth/auth_elevated_button.dart';
import '../../widgets/auth/auth_header_image.dart';
import '../../widgets/auth/auth_text_form_field.dart';
import '../../widgets/forgot_password/linear_gradient_title.dart';
import '../../widgets/forgot_password/message_content.dart';
import '../../widgets/forgot_password/stacks_bottom.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with Validator {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;

  late ValueNotifier<bool> _isLoading;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _isLoading = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                  text: "TYPE YOUR EMAIL",
                  textStyle: AppTheme.forgotPasswordLabelStyle,
                ),
                const SizedBox(
                  height: 15,
                ),
                const MessageContent(
                    text:
                        "We will send you instruction on how to reset your password"),
                const SizedBox(
                  height: 25,
                ),
                Form(
                  key: _formKey,
                  child: AuthTextFormField(
                    textEditingController: _emailController,
                    hintText: "Email",
                    textInputAction: TextInputAction.done,
                    validator: (value) => validateEmail(value),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) => AuthElevatedButton(
                    width: double.infinity,
                    height: 45,
                    inputText: "SEND",
                    onPressed: () => context
                        .read<ForgotPasswordCubit>()
                        .sendPasswordResetEmail(
                          context,
                          _formKey,
                          _emailController.text.trim(),
                        ),
                    isLoading: (state is ForgotPasswordLoading ? true : false),
                  ),
                ),
                const SizedBox(
                  height: 40,
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
