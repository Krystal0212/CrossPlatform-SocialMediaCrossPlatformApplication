import 'package:socialapp/utils/import.dart';

class VerificationCubit extends Cubit<VerificationState> with AppDialogs {
  VerificationCubit() : super(VerificationInitial());

  void verification(BuildContext context, GlobalKey<FormState> formKey, String code) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(VerificationLoading());
        await serviceLocator<DeepLinkRepository>().generateVerifyLink("123456");
        emit(VerificationSuccess());
      }
    } catch (error) {
      emit(VerificationFailure());

      if(!context.mounted) return;
      showAlertDialog(context, AppStrings.error, error.toString());
    }
  }
}
