import 'package:socialapp/utils/import.dart';

mixin AppDialogs {
  void showSimpleAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool isError,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Center(
            child: LinearGradientTitle(
              text: title,
              textStyle: TextStyle(
                  fontSize: 17,
                  color: isError ? Colors.red : Colors.lightBlueAccent),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5);
                    } else {
                      return AppColors.iris;
                    }
                  },
                ),
              ),
              onPressed: () {
                Navigator.of(builderContext).pop();
              },
              child: const Text(
                "Okay",
                style: TextStyle(color: Colors.white),
              ),
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
              if (hasCancel)
                TextButton(
                  onPressed: () {
                    Navigator.of(builderContext).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(builderContext).pop();
                  navigateFunction();
                },
                child: const Text("Okay"),
              )
            ],
          );
        });
  }
}
