import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/data/sources/auth/auth_firebase_service.dart';
import 'package:socialapp/presentation/screens/forgot_pasword/cubit/forgot_password_state.dart';
import 'package:socialapp/service_locator.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void sendPasswordResetEmail(
      BuildContext context, GlobalKey<FormState> formKey, String email) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(ForgotPasswordLoading());
        await serviceLocator<AuthFirebaseService>()
            .sendPasswordResetEmail(email);
        emit(ForgotPasswordSuccess());
        _showAlertDialog(context, "Success",
            "Send reset password email success. Please check your mail to reset password");
        // context.go("/signin/forgotpassword/verification");
      }
    } catch (e) {
      emit(ForgotPasswordFailure());
      if (e is FirebaseAuthException) {
        if (e.code == "email-not-found") {
          _showAlertDialog(context, "Error", e.message);
        } else {
          if (kDebugMode) {
            print("Error send password reset email: $e");
          }
        }
      } else {
        if (kDebugMode) {
          print("Error send password reset email: $e");
        }
      }
    }
  }

  void _showAlertDialog(BuildContext context, String? title, String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "$title",
            textAlign: TextAlign.center,
          ),
          content: Text("$message"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }
}
