import 'package:socialapp/utils/import.dart';

import 'cubit/create_password_cubit.dart';
import 'cubit/create_password_state.dart';

class CreatePasswordScreen extends StatelessWidget {
  final BuildContext parentContext;

  const CreatePasswordScreen({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CreatePasswordCubit(),
        child:  CreatePasswordDialog(parentContext: parentContext,));
  }
}

class CreatePasswordDialog extends StatefulWidget {
  final BuildContext parentContext;

  const CreatePasswordDialog({super.key, required this.parentContext});

  @override
  State<CreatePasswordDialog> createState() => _CreatePasswordDialogState();
}

class _CreatePasswordDialogState extends State<CreatePasswordDialog>
    with Validator, FlashMessage {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;

  late final FocusNode _newPasswordFocus;
  late final FocusNode _confirmNewPasswordFocus;

  late ValueNotifier<bool> _obscureText;
  late ValueNotifier<bool> _obscureConfirmText;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    _newPasswordFocus = FocusNode();
    _confirmNewPasswordFocus = FocusNode();

    _obscureText = ValueNotifier<bool>(true);
    _obscureConfirmText = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    _newPasswordFocus.dispose();
    _confirmNewPasswordFocus.dispose();

    _obscureText.dispose();
    _obscureConfirmText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'SET NEW PASSWORD',
                style: AppTheme.dialogHeaderStyle,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    ValueListenableBuilder(
                      valueListenable: _obscureText,
                      builder: (context, value, child) {
                        return AuthTextFormField(
                          textEditingController: _newPasswordController,
                          hintText: AppStrings.newPasswordHint,
                          obscureText: value,
                          focusNode: _newPasswordFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmNewPasswordFocus),
                          validator: (value) => validatePassword(value),
                          suffixIcon: IconButton(
                            onPressed: () => _obscureText.value = !value,
                            icon: Icon(value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder(
                      valueListenable: _obscureConfirmText,
                      builder: (context, value, child) {
                        return AuthTextFormField(
                          textEditingController: _confirmNewPasswordController,
                          hintText: AppStrings.newConfirmPasswordHint,
                          obscureText: value,
                          focusNode: _confirmNewPasswordFocus,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _confirmNewPasswordFocus.unfocus(), // Close keyboard
                          validator: (value) => validateConfirmPassword(_newPasswordController.text, value),
                          suffixIcon: IconButton(
                            onPressed: () => _obscureConfirmText.value = !value,
                            icon: Icon(value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<CreatePasswordCubit, CreatePasswordState>(
                listener: (context, state) {
                  if (state is CreatePasswordSuccess) {
                    Navigator.pop(context, true);
                    showSuccessMessage(
                      context: context,
                      title: 'Password Changed',
                    );
                  }
                },
                builder: (context, state) => AuthElevatedButton(
                  width: double.infinity,
                  height: 45,
                  inputText: AppStrings.submit,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    context.read<CreatePasswordCubit>().setPassword(
                      context,
                      _formKey,
                      newPassword: _newPasswordController.text,
                    );
                  },
                  isLoading: state is CreatePasswordLoading,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppTheme.authSignUpStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
