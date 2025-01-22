
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

  void showUploadLimitExceededMassage(
      {required BuildContext context}) {
    PulpFlash.of(context).showMessage(
      context,
      inputMessage: Message(
        status: FlashStatus.error,
        title: AppStrings.limitUploadExceed,
        displayDuration: const Duration(seconds: 3),
      ),
    );
  }

    void showUnknownMessage(
        {required BuildContext context, required String label}) {
      PulpFlash.of(context).showMessage(
        context,
        inputMessage: Message(
          status: FlashStatus.error,
            title: label,
          displayDuration: const Duration(seconds: 3),
        ),
      );
    }

  void showSuccessMessage(
      {required BuildContext context, required String description}) {
    PulpFlash.of(context).showMessage(
      context,
      inputMessage: Message(
        status: FlashStatus.successful,
        title: description,
        displayDuration: const Duration(seconds: 3),
      ),
    );
  }

  void showAttentionMessage(
      {required BuildContext context, required String description}) {
    PulpFlash.of(context).showMessage(
      context,
      inputMessage: Message(
        status: FlashStatus.warning,
        title: description,
        displayDuration: const Duration(seconds: 8),
      ),
    );
  }


}
