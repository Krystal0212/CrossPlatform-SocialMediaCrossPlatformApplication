import 'package:socialapp/utils/import.dart';

import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> with AppDialogs {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  void verifyPasswordRequestByLink(
      BuildContext context, String encryptedLink) async {
    try {
      if (encryptedLink.isNotEmpty) {
        emit(VerifyRequestLoading());
        await serviceLocator<AuthRepository>()
            .verifyResetPasswordRequestByOTPLink(encryptedLink);
        emit(VerifyRequestSuccess());
      }
    } catch (error) {
      emit(VerifyRequestFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showNavigateAlertDialog(
          context: context,
          title: AppStrings.error,
          message: 'The link is invalid or expired',
          navigateFunction: () {
            context.go('/home');
          });
    }
  }

  void setNewPassword(String password) async {
    try {
      emit(ResetPasswordLoading());
      await serviceLocator<AuthRepository>().resetPassword(password);
      emit(ResetPasswordSuccess());
    } catch (error) {}
  }
}
