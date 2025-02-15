import 'package:socialapp/utils/import.dart';
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
  late ValueNotifier<int> _countdownNotifier;
  late Timer? _timer;

  @override
  void initState() {
    final dynamicLinkService = DeepLinkServiceImpl();
    dynamicLinkService.handleIncomingLinks(AppRoutes.router);

    _formKey = GlobalKey<FormState>();
    _codeController = TextEditingController();
    _verifyMessageChangeNotifier =
        ValueNotifier<String>(AppStrings.messageDefault);

    _countdownNotifier = ValueNotifier<int>(0);
    _timer = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String hash = widget.hashParameters ?? "";

      if (hash.isNotEmpty) {
        context.read<VerificationCubit>().verifyAccountByLink(context, hash);
      } else if (!context
          .read<VerificationCubit>()
          .checkNecessaryConditionToUseScreen(
              context, widget.isFromSignIn ?? false)) {
        context.go('/home');
      }
    });

    FlutterNativeSplash.remove();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWeb = PlatformConfig.of(context)?.isWeb ?? false;
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;

    context.read<VerificationCubit>().managePageState(
        context, widget.isFromSignIn, _verifyMessageChangeNotifier);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _verifyMessageChangeNotifier.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownNotifier.value = 30; // Set 30 seconds countdown
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNotifier.value > 0) {
        _countdownNotifier.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!kIsWeb) {
          context.go('/sign-in');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Material(
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
                    marginTop: deviceHeight * 0.12,
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
                            // AuthTextFormField(
                            //     textEditingController: _codeController,
                            //     hintText: AppStrings.typeCode),

                            BlocBuilder<VerificationCubit, VerificationState>(
                                builder: (context, state) {
                              return Column(
                                children: [
                                  if (state is! VerificationLoadingFromSignIn)
                                    PinCodeTextFieldWidget(
                                        onCompleted: (String value) {
                                      context
                                          .read<VerificationCubit>()
                                          .verifyByCode(context, value);
                                    }),
                                  if (state is! VerificationLoadingFromSignIn)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (state is! VerificationLoadingFromSignIn)
                                    ValueListenableBuilder<int>(
                                      valueListenable: _countdownNotifier,
                                      builder: (context, seconds, child) {
                                        return TextButton(
                                          onPressed: seconds == 0
                                              ? () {
                                                  _startCountdown();
                                                  context
                                                      .read<VerificationCubit>()
                                                      .sendVerifyEmail(
                                                          _verifyMessageChangeNotifier);
                                                }
                                              : null,
                                          // Disable button if countdown is active
                                          child: Text(
                                            seconds == 0
                                                ? AppStrings.notReceiveTheCode
                                                : "Remember to check your spam box. Resend in $seconds s",
                                            style: TextStyle(
                                              color: seconds == 0
                                                  ? AppColors.lightIris
                                                  : AppColors.trolleyGrey, // Gray out when disabled
                                            ),
                                          ),
                                        );
                                      },
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
                                      FocusScope.of(context).unfocus();
                                      if (state
                                          is VerificationLoadingFromSignIn) {
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
        ),
      ),
    );
  }
}
