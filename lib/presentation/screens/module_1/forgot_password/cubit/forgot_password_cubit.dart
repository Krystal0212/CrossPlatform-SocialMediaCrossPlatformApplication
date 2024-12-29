import 'package:socialapp/utils/import.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> with AppDialogs {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void sendPasswordResetEmail(
      BuildContext context, GlobalKey<FormState> formKey, String email) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(ForgotPasswordLoading());
        await serviceLocator<AuthFirebaseService>()
            .sendPasswordResetEmail(email);

        emit(ForgotPasswordSuccess());

        if (context.mounted) {
          showSimpleAlertDialog(
              context: context,
              title: "Success",
              message:
                  "Send reset password email success. Please check your mail to reset password");
        }
        // Go to otp verify screen with passType = resetEmail using
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (kDebugMode) {
          print("Error firebase auth error: $e");
        }
      } else {
        if (kDebugMode) {
          print("Error send password reset email: $e");
        }
      }
      emit(ForgotPasswordFailure());
    }
  }
}
