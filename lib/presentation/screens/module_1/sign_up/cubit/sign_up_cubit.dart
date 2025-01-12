import 'sign_up_state.dart';
import 'package:socialapp/utils/import.dart';

class SignUpCubit extends Cubit<SignUpState> with AppDialogs {
  SignUpCubit() : super(SignUpInitial());

  void signup(BuildContext context, GlobalKey<FormState> formKey,
      SignUpUserReq signUpUserReq) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(SignUpLoading());
        await serviceLocator<AuthRepository>().signUp(signUpUserReq);
        emit(SignUpSuccess());
      }
    } catch (error) {
      emit(SignUpFailure());

      if (!context.mounted) return;
      showSimpleAlertDialog(
        context: context,
        title: AppStrings.error,
        message: error.toString(),
        isError: true,
      );
    }
  }
}
