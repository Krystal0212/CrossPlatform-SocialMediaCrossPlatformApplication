import 'package:socialapp/utils/import.dart';

import 'create_password_state.dart';

class CreatePasswordCubit extends Cubit<CreatePasswordState> with AppDialogs {


  CreatePasswordCubit() : super(CreatePasswordInitial());

  void setPassword(BuildContext context, GlobalKey<FormState> formKey,
  { required String newPassword}) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(CreatePasswordLoading());
        await serviceLocator<AuthRepository>().setPasswordForGoogleUser(newPassword);
        emit(CreatePasswordSuccess());
      }
    } catch (error) {
      emit(CreatePasswordFailure());
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
