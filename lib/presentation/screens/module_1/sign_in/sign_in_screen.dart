import 'package:socialapp/presentation/screens/module_1/sign_in/widgets/custom_google_button.dart';
import 'package:socialapp/utils/import.dart';

import 'cubit/sign_in_cubit.dart';
import 'cubit/sign_in_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with Validator {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late ValueNotifier<bool> _obscureText;
  late bool _isWeb;
  late double deviceWidth, deviceHeight;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _obscureText = ValueNotifier<bool>(true);
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
    _emailController.dispose();
    _passwordController.dispose();
    _obscureText.dispose();
    super.dispose();
  }

  // CanPopState
  Future<bool> _showBackDialog() async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(AppStrings.exitDialogTitle),
              content: const Text(AppStrings.exitDialogContent),
              actions: <Widget>[
                TextButton(
                  child: const Text(AppStrings.exitDialogNo),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text(AppStrings.exitDialogYes),
                  onPressed: () {
                    SystemNavigator.pop();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignInCubit(),
      child: Material(
        child: BackgroundContainer(
          center: AuthSizedBox(
            isWeb: _isWeb,
            deviceWidth: deviceWidth,
            deviceHeight: deviceHeight,
            child: Stack(
              children: [
                AuthHeaderImage(
                  isWeb: _isWeb,
                  heightRatio: 0.42,
                  childAspectRatio: 1.41,
                  positioned: Positioned.fill(
                    top: (_isWeb) ? 0 : -45,
                    child: Center(
                      child: Text(
                        AppStrings.welcome,
                        style: AppTheme.authHeaderStyle,
                      ),
                    ),
                  ),
                ),
                AuthBody(
                  isWeb: _isWeb,
                  marginTop: deviceHeight * 0.32,
                  height: deviceHeight * (1 - 0.32),
                  child: AuthScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AuthTextFormField(
                                textEditingController: _emailController,
                                hintText: AppStrings.email,
                                textInputAction: TextInputAction.next,
                                validator: (value) => validateEmail(value),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ValueListenableBuilder(
                                valueListenable: _obscureText,
                                builder: (context, value, child) {
                                  return AuthTextFormField(
                                    textEditingController: _passwordController,
                                    hintText: AppStrings.passwordHint,
                                    obscureText: value,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) =>
                                        validateSignInPassword(value),
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
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          style: AppTheme.navigationTextButtonStyle,
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: AppTheme.authForgotStyle,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<SignInCubit, SignInState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                AuthElevatedButton(
                                  width: deviceWidth,
                                  height: 45,
                                  inputText: AppStrings.logIn,
                                  onPressed: () => context
                                      .read<SignInCubit>()
                                      .loginWithEmailAndPassword(
                                        context,
                                        _formKey,
                                        SignInUserReq(
                                            email: _emailController.text,
                                            password: _passwordController.text),
                                      ),
                                  isLoading:
                                      (state is SignInLoading ? true : false),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  AppStrings.orLogInBy,
                                  style: AppTheme.authNormalStyle,
                                ),
                                GoogleButton(
                                  onPressed: () => context
                                      .read<SignInCubit>()
                                      .loginWithGoogle(context),
                                )
                              ],
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.noAccount,
                              style: AppTheme.authSignUpStyle
                                  .copyWith(color: AppColors.kettleman),
                            ),
                            const SizedBox(width: 5),
                            TextButton(
                              style: AppTheme.navigationTextButtonStyle,
                              onPressed: () => context.go('/sign-up'),
                              child: Text(
                                AppStrings.signUp,
                                style: AppTheme.authSignUpStyle,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
