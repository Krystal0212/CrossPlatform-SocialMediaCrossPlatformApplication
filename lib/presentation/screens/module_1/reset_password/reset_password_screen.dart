import 'package:socialapp/presentation/screens/module_1/reset_password/cubit/reset_password_state.dart';
import 'package:socialapp/utils/import.dart';

import 'cubit/reset_password_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? hashParameters;

  const ResetPasswordScreen({super.key, this.hashParameters});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with Validator {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late ValueNotifier<bool> _obscureText;
  late ValueNotifier<bool> _obscureConfirmText;
  late double deviceWidth, deviceHeight;
  late bool _isWeb;
  late String uid;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _formKey = GlobalKey<FormState>();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _obscureText = ValueNotifier<bool>(true);
    _obscureConfirmText = ValueNotifier<bool>(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String hash = widget.hashParameters ?? "";

      if (hash.isNotEmpty) {
        context
            .read<ResetPasswordCubit>()
            .verifyPasswordRequestByLink(context, hash);
      } else {
        context.go('/home');
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWeb = PlatformConfig.of(context)?.isWeb ?? false;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _obscureText.dispose();
    _obscureConfirmText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BackgroundContainer(
        center: AuthSizedBox(
          isWeb: _isWeb,
          deviceWidth: deviceWidth,
          deviceHeight: deviceHeight,
          child: Stack(
            children: [
              AuthHeaderImage(
                heightRatio: 0.36,
                childAspectRatio: 1.85,
                isWeb: _isWeb,
              ),
              AuthBody(
                isWeb: _isWeb,
                marginTop: deviceHeight * 0.26,
                height: deviceHeight,
                child: AuthScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LinearGradientTitle(
                          text: AppStrings.setNewPassword,
                          textStyle: AppTheme.forgotPasswordLabelStyle,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const MessageContent(
                          text: AppStrings.typeNewPassword,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _obscureText,
                          builder: (context, value, child) {
                            return AuthTextFormField(
                              textEditingController: _passwordController,
                              hintText: AppStrings.passwordHint,
                              obscureText: value,
                              textInputAction: TextInputAction.next,
                              validator: (value) => validatePassword(value),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _obscureText.value = !value;
                                },
                                icon: Icon(value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _obscureConfirmText,
                          builder: (context, value, child) {
                            return AuthTextFormField(
                              textEditingController: _confirmPasswordController,
                              hintText: AppStrings.confirmPasswordHint,
                              obscureText: value,
                              textInputAction: TextInputAction.done,
                              validator: (value) => validateConfirmPassword(
                                  _passwordController.text, value),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _obscureConfirmText.value = !value;
                                },
                                icon: Icon(value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                            builder: (context, state) {
                          return Column(
                            children: [
                              AuthElevatedButton(
                                width: deviceWidth,
                                height: 52,
                                inputText: AppStrings.send,
                                onPressed: () async {
                                  context
                                      .read<ResetPasswordCubit>()
                                      .setNewPassword(
                                          context,
                                          _confirmPasswordController.text
                                              .trim());
                                },
                                isLoading: (state is VerifyRequestLoading ||
                                    state is ResetPasswordLoading),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        const StacksBottom(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
