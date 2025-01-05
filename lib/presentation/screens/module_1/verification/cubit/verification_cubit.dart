import 'package:socialapp/utils/import.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> with AppDialogs {
  VerificationCubit() : super(VerificationInitial());

  bool checkNecessaryConditionToUseScreen(
      BuildContext context, bool isFromSignIn) {
    try {
      if (isFromSignIn == false) {
        return false;
      } else if (serviceLocator<AuthRepository>().isUserVerified()) {
        return false;
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  void verifyAccountByLink(BuildContext context, String encryptedLink) async {
    try {
      if (encryptedLink.isNotEmpty) {
        emit(VerificationLoading());
        await serviceLocator<AuthRepository>()
            .verifyAccountByOTPLink(encryptedLink);
        emit(VerificationSuccess());

        if (context.mounted) {
          context.go('/home');
        }
      }
    } catch (error) {
      emit(VerificationFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showSimpleAlertDialog(
          context: context,
          title: AppStrings.error,
          message: 'The link is invalid or expired');
    }
  }

  void verifyByCode(BuildContext context, String otpCode) async {
    try {
      if (otpCode.isNotEmpty) {
        emit(VerificationLoading());
        await serviceLocator<AuthRepository>().verifyAccountByOTPCode(otpCode);

        if(!context.mounted) return;
        context.go('/home');
        emit(VerificationSuccess());
      }
    } catch (error) {
      emit(VerificationFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showSimpleAlertDialog(
          context: context,
          title: AppStrings.error,
          message: 'The code is invalid or expired');
    }
  }

  void managePageState(BuildContext context, bool? isFromSignIn,
      ValueNotifier<String> verifyMessageChangeNotifier) async {
    try {
      User? user = await serviceLocator<AuthRepository>().getCurrentUser();

      if (user != null) {
        // For sign in page in case email is not verified
        if (isFromSignIn == true) {
          verifyMessageChangeNotifier.value = AppStrings.messageNotVerifiedYet;
          emit(VerificationLoadingFromSignIn());
        } else {
          verifyMessageChangeNotifier.value = AppStrings.messageDefault;
        }
      } else {
        emit(VerificationNoUserSignedIn());
        if (context.mounted) {
          showNavigateAlertDialog(
              context: context,
              title: "No User Signed In",
              hasCancel: false,
              message: "It seems you are not signed in. Sign in first please",
              navigateFunction: () {
                if (context.mounted) {
                  context.go('/sign-in');
                }
              });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }

      VerificationFailure(errorMessage: 'An error occurred: $e');
    }
  }

  void sendVerifyEmail(
      ValueNotifier<String> verifyMessageChangeNotifier) async {
    try {
      emit(VerificationLoading());
      await serviceLocator<AuthRepository>()
          .sendForCurrentUserVerificationEmail();
      verifyMessageChangeNotifier.value = AppStrings.messageDefault;
      emit(VerificationSentEmail());
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }

      VerificationFailure(errorMessage: 'An error occurred: $e');
    }
  }
}
