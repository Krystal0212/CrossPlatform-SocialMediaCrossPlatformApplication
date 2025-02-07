import 'change_password_state.dart';
import 'package:socialapp/utils/import.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> with AppDialogs {


  ChangePasswordCubit() : super(ChangePasswordInitial());

  void changePassword(BuildContext context, GlobalKey<FormState> formKey,
  {required String currentPassword, required String newPassword}) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(ChangePasswordLoading());
        await serviceLocator<AuthRepository>().changePassword(currentPassword, newPassword);
        emit(ChangePasswordSuccess());
      }
    } catch (error) {
      emit(ChangePasswordFailure());
      if (error is FirebaseAuthException && error.code == 'invalid-credential') {
        if (!context.mounted) return;
        showSimpleAlertDialog(
          context: context,
          title: AppStrings.error,
          message: 'Wrong password.',
          isError: true);
        return;
      }

      if (!context.mounted) return;
      showSimpleAlertDialog(
        context: context,
        title: AppStrings.error,
        message: 'Please try again later.',
        isError: true,
      );

      if (kDebugMode) {
        print('Error during change password: $error');
      }
    }
  }
}
