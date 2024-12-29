import 'package:socialapp/utils/import.dart';
import 'cubit/verification_cubit.dart';
import 'cubit/verification_state.dart';

class VerificationScreen extends StatefulWidget {
  final String? hashParameters;
  final bool? isFromSignIn;

  const VerificationScreen({
    super.key,
    this.hashParameters,
    this.isFromSignIn,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _codeController;
  late ValueNotifier<String> _verifyMessageChangeNotifier;
  late double deviceWidth, deviceHeight;
  late bool _isWeb;

  @override
  void initState() {
    FlutterNativeSplash.remove();

    _formKey = GlobalKey<FormState>();
    _codeController = TextEditingController();
    _verifyMessageChangeNotifier = ValueNotifier<String>("");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String hash = widget.hashParameters ?? "";

      if (hash.isNotEmpty) {
        // if (widget.isResetPassword == true) {
        //   context
        //       .read<VerificationCubit>()
        //       .verifyResetPasswordRequestByLink(context, hash);
        // } else {
        context.read<VerificationCubit>().verifyAccountByLink(context, hash);
        // }
      } else if (!context
          .read<VerificationCubit>()
          .checkNecessaryConditionToUseScreen(
              context, widget.isFromSignIn ?? false)) {
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

    context.read<VerificationCubit>().managePageState(
        context, widget.isFromSignIn, _verifyMessageChangeNotifier);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _verifyMessageChangeNotifier.dispose();
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
                          text: AppStrings.verification,
                          textStyle: AppTheme.forgotPasswordLabelStyle,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ValueListenableBuilder(
                            valueListenable: _verifyMessageChangeNotifier,
                            builder: (context, value, child) {
                              return MessageContent(
                                text: value,
                              );
                            }),
                        const SizedBox(
                          height: 30,
                        ),
                        AuthTextFormField(
                            textEditingController: _codeController,
                            hintText: AppStrings.typeCode),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<VerificationCubit, VerificationState>(
                            builder: (context, state) {
                          return Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (state is VerificationLoadingFromSignIn) {
                                    context.go('/sign-in');
                                  } else {
                                    context
                                        .read<VerificationCubit>()
                                        .sendVerifyEmail(
                                            _verifyMessageChangeNotifier);
                                  }
                                },
                                child: Text(
                                  (state is VerificationLoadingFromSignIn)
                                      ? "Cancel"
                                      : AppStrings.notReceiveTheCode,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              AuthElevatedButton(
                                width: deviceWidth,
                                height: 52,
                                inputText:
                                    state is VerificationLoadingFromSignIn
                                        ? AppStrings.buttonSendToMyEmail
                                        : AppStrings.verify,
                                onPressed: () async {
                                  if (state is VerificationLoadingFromSignIn) {
                                    context
                                        .read<VerificationCubit>()
                                        .sendVerifyEmail(
                                            _verifyMessageChangeNotifier);
                                  } else {
                                    context
                                        .read<VerificationCubit>()
                                        .verifyByCode(
                                            context, _codeController.text);
                                  }
                                },
                                isLoading: (state is VerificationLoading),
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
