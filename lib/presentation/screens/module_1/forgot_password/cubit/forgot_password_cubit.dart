import 'package:socialapp/utils/import.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> with AppDialogs {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void sendPasswordResetEmail(
      BuildContext context, GlobalKey<FormState> formKey, String email) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(ForgotPasswordLoading());
        await serviceLocator<AuthRepository>().sendPasswordResetEmail(email);

        emit(ForgotPasswordSuccess());

        if (context.mounted) {
          showSimpleAlertDialog(
            context: context,
            title: "Success",
            message: "An email has been sent to your email."
                " Please check it out to reset your password !",
            isError: false,
          );
        }
        // Go to otp verify screen with passType = resetEmail using
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Recipient email not found')) {
        errorMessage =
            'The email address is not registered. Please check your input.';
      } else if (e.toString().contains('Bad request:')) {
        errorMessage = 'Please verify your email before doing this action.';
      } else if (e.toString().contains('Internal server error')) {
        errorMessage =
            'Our system is currently experiencing issues. Please try again later.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      if (context.mounted) {
        showSimpleAlertDialog(
          context: context,
          title: "An error has occurred",
          message: errorMessage,
          isError: true,
        );
      }
      emit(ForgotPasswordFailure());
    }
  }
}
