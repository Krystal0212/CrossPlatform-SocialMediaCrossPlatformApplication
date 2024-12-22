import 'package:socialapp/utils/import.dart';

class VerificationCubit extends Cubit<VerificationState> with AppDialogs {
  VerificationCubit() : super(VerificationInitial());

  void verifyByLink(BuildContext context, String encryptedLink) async {
    try {
      if (encryptedLink.isNotEmpty) {
        emit(VerificationLoading());
        await serviceLocator<AuthRepository>().verifyOTPByLink(encryptedLink);
        emit(VerificationSuccess());
      }
    } catch (error) {
      emit(VerificationFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showAlertDialog(
          context, AppStrings.error, 'The link is invalid or expired');
    }
  }

  void verifyByCode(BuildContext context, String otpCode) async {
    try {
      if (otpCode.isNotEmpty) {
        emit(VerificationLoading());
        await serviceLocator<AuthRepository>().verifyOTPByCode(otpCode);
        emit(VerificationSuccess());
      }
    } catch (error) {
      emit(VerificationFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showAlertDialog(
          context, AppStrings.error, 'The code is invalid or expired');
    }
  }
}
