import 'package:socialapp/utils/import.dart';

mixin FlashMessage {
  void showNotSignedInMassage(
      {required BuildContext context, required String description}) {
    PulpFlash.of(context).showMessage(
      context,
      inputMessage: Message(
        status: FlashStatus.error,
        title: AppStrings.notSignedInTitle,
        description: description,
        displayDuration: const Duration(seconds: 3),
      ),
    );
  }
}
