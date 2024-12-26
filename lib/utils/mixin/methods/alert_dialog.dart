import 'package:socialapp/utils/import.dart';

mixin AppDialogs {
  void showSimpleAlertDialog({
      required BuildContext context, required String title,
      required String message,}) {
    showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(builderContext).pop();
              },
              child: const Text("Okay"),
            )
          ],
        );
      },
    );
  }

  void showNavigateAlertDialog(
      {required BuildContext context,
      required String title,
      required String message,
      required void Function() navigateFunction,
      bool hasCancel = true}) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Text(message),
            actions: [
              if (hasCancel)TextButton(
                onPressed: () {
                  Navigator.of(builderContext).pop(); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(builderContext).pop();
                  navigateFunction;
                },
                child: const Text("Okay"),
              )
            ],
          );
        });
  }
}
