import 'package:socialapp/utils/import.dart';
import 'cubit/forgot_password_cubit.dart';
import 'cubit/forgot_password_state.dart';

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
  late double deviceWidth, deviceHeight;
  late bool _isWeb;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _isLoading = ValueNotifier<bool>(false);
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
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: Material(
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
                    child: Column(
                      children: [
                        LinearGradientTitle(
                          text: "TYPE YOUR EMAIL",
                          textStyle: AppTheme.forgotPasswordLabelStyle,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const MessageContent(
                            text: AppStrings.defaultResetPasswordMessage, ),
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
                            width: deviceWidth,
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
                          height: 20,
                        ),
                        const StacksBottom(),
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
