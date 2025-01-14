import 'package:socialapp/utils/import.dart';

import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> with AppDialogs {
  String? userUid;

  ResetPasswordCubit() : super(ResetPasswordInitial());

  void verifyPasswordRequestByLink(
      BuildContext context, String encryptedLink) async {
    try {
      if (encryptedLink.isNotEmpty) {
        emit(VerifyRequestLoading());
        userUid = await serviceLocator<AuthRepository>()
            .verifyResetPasswordRequestByOTPLink(encryptedLink);
        emit(VerifyRequestSuccess());
      }
    } catch (error) {
      emit(VerifyRequestFailure(errorMessage: error.toString()));

      if (!context.mounted) return;
      showNavigateAlertDialog(
          context: context,
          title: AppStrings.error,
          hasCancel: false,
          message: 'The link is invalid or expired: ${error.toString()}',
          navigateFunction: () {
            context.go('/home');
          });
    }
  }

  void setNewPassword(BuildContext context, String password) async {
    try {
      emit(ResetPasswordLoading());

      if (userUid == null) {
        throw 'User ID not found. Please verify the link again.';
      }

      await serviceLocator<AuthRepository>().resetPassword(password, userUid!);
      emit(ResetPasswordSuccess());
      if (context.mounted) {
        showNavigateAlertDialog(
            context: context,
            title: AppStrings.success,
            hasCancel: false,
            message: 'Password reset successfully',
            navigateFunction: () {
              context.go('/sign-in');
            });
      }
    } catch (error) {
      emit(ResetPasswordFailure(errorMessage: error.toString()));
      if (context.mounted) {
        showSimpleAlertDialog(
          context: context,
          title: AppStrings.error,
          message: error.toString(),
          isError: true,
        );
      }
    }
  }
}
