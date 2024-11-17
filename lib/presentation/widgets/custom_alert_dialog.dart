import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/themes.dart';

class CustomAlertDialog {
  final String titleText;
  final String contentText;
  final VoidCallback submitFunction;
  final String submitButtonText; // Customizable submit button text
  final VoidCallback? cancelFunction;
  final String? cancelButtonText; // Optional cancel button text
  final bool showCancelButton;

  CustomAlertDialog({
    required this.titleText,
    required this.contentText,
    required this.submitFunction,
    this.submitButtonText = 'Submit', // Default submit text
    this.cancelFunction,
    this.cancelButtonText = 'Cancel', // Default cancel text
    this.showCancelButton = true, // Default to true, cancel button visible by default
  });

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(titleText, style: AppTheme.blackHeaderStyle,),
          content: Text(contentText ,style: AppTheme.appHintStyle,),
          actions: <Widget>[
            if (showCancelButton) // Conditionally render Cancel button
              TextButton(
                onPressed: () {
                  if (cancelFunction != null) {
                    cancelFunction!();
                  }
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text(cancelButtonText!), // Custom cancel button text
              ),
            TextButton(
              onPressed: submitFunction,
              child: Text(submitButtonText), // Custom submit button text
            ),

          ],
        );
      },
    );
  }
}
