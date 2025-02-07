import 'package:socialapp/utils/import.dart';

import 'cubit/change_password_cubit.dart';
import 'cubit/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  final BuildContext parentContext;

  const ChangePasswordScreen({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ChangePasswordCubit(),
        child: ChangePasswordDialog(
          parentContext: parentContext,
        ));
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final BuildContext parentContext;

  const ChangePasswordDialog({super.key, required this.parentContext});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog>
    with Validator, FlashMessage {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;

  late final FocusNode _currentPasswordFocus;
  late final FocusNode _newPasswordFocus;
  late final FocusNode _confirmNewPasswordFocus;

  late ValueNotifier<bool> _obscureCurrentText;
  late ValueNotifier<bool> _obscureText;
  late ValueNotifier<bool> _obscureConfirmText;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    _currentPasswordFocus = FocusNode();
    _newPasswordFocus = FocusNode();
    _confirmNewPasswordFocus = FocusNode();

    _obscureCurrentText = ValueNotifier<bool>(true);
    _obscureText = ValueNotifier<bool>(true);
    _obscureConfirmText = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmNewPasswordFocus.dispose();

    _obscureCurrentText.dispose();
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
                'CHANGE PASSWORD',
                style: AppTheme.dialogHeaderStyle,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _obscureCurrentText,
                      builder: (context, value, child) {
                        return AuthTextFormField(
                          textEditingController: _currentPasswordController,
                          hintText: AppStrings.currentPasswordHint,
                          obscureText: value,
                          focusNode: _currentPasswordFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_newPasswordFocus),
                          validator: (value) {
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed: () => _obscureCurrentText.value = !value,
                            icon: Icon(value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                          ),
                        );
                      },
                    ),
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
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_confirmNewPasswordFocus),
                          validator: (value) => validatePassword(value),
                          suffixIcon: IconButton(
                            onPressed: () => _obscureText.value = !value,
                            icon: Icon(value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
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
                          onFieldSubmitted: (_) =>
                              _confirmNewPasswordFocus.unfocus(),
                          // Close keyboard
                          validator: (value) => validateConfirmPassword(
                              _newPasswordController.text, value),
                          suffixIcon: IconButton(
                            onPressed: () => _obscureConfirmText.value = !value,
                            icon: Icon(value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                listener: (context, state) {
                  if (state is ChangePasswordSuccess) {
                    Navigator.pop(context);
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
                    context.read<ChangePasswordCubit>().changePassword(
                          context,
                          _formKey,
                          currentPassword: _currentPasswordController.text,
                          newPassword: _newPasswordController.text,
                        );
                  },
                  isLoading: state is ChangePasswordLoading,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
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
