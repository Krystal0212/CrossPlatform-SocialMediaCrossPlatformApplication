import 'package:socialapp/utils/import.dart';

import 'cubit/sign_up_cubit.dart';
import 'cubit/sign_up_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with Validator {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late ValueNotifier<bool> _obscureText;
  late ValueNotifier<bool> _obscureConfirmText;
  late double deviceWidth, deviceHeight;
  late bool _isWeb;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _obscureText = ValueNotifier<bool>(true);
    _obscureConfirmText = ValueNotifier<bool>(true);
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
    _confirmPasswordController.dispose();
    _obscureText.dispose();
    _obscureConfirmText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: Material(
        child: BackgroundContainer(
          center: AuthSizedBox(
            isWeb: _isWeb,
            deviceWidth: deviceWidth,
            deviceHeight: deviceHeight,
            child: Stack(children: [
              AuthHeaderImage(
                heightRatio: 0.42,
                childAspectRatio: 1.41,
                isWeb: _isWeb,
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
                marginTop: deviceHeight * 0.32,
                height: deviceHeight,
                isWeb: _isWeb,
                child: AuthScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthTextFormField(
                              textEditingController: _emailController,
                              hintText: AppStrings.emailHint,
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
                              height: 15,
                            ),
                            ValueListenableBuilder(
                              valueListenable: _obscureConfirmText,
                              builder: (context, value, child) {
                                return AuthTextFormField(
                                  textEditingController:
                                      _confirmPasswordController,
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      BlocConsumer<SignUpCubit, SignUpState>(
                        listener: (context, state) {
                          if (state is SignUpSuccess) {
                            context.go('/verify');
                          }
                        },
                        builder: (context, state) => AuthElevatedButton(
                          width: deviceWidth,
                          height: 45,
                          inputText: AppStrings.signUpUppercase,
                          onPressed: () => context.read<SignUpCubit>().signup(
                              context, _formKey,
                              email: _emailController.text,
                              password: _passwordController.text),
                          isLoading: (state is SignUpLoading ? true : false),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: AppTheme.authSignUpStyle
                                .copyWith(color: AppColors.kettleman),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          TextButton(
                            style: AppTheme.navigationTextButtonStyle,
                            onPressed: () => context.go('/sign-in'),
                            child: Text(
                              AppStrings.signInUppercase,
                              style: AppTheme.authSignUpStyle,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
