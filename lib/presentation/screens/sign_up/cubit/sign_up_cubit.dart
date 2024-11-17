import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/sign_up/cubit/sign_up_state.dart';

import '../../../../data/models/auth/create_user_req.dart';
import '../../../../domain/repository/auth/auth_repository.dart';
import '../../../../service_locator.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  void signup(BuildContext context, GlobalKey<FormState> formKey,
      SignUpUserReq signUpUserReq) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(SignUpLoading());
        await serviceLocator<AuthRepository>().signUp(signUpUserReq);
        emit(SignUpSuccess());
        _showAlertDialog(context, "Success",
            "An email has just been sent to you, click the link provided to complete registration");
      }
    } catch (e) {
      emit(SignUpFailure());
      _showAlertDialog(context, "Error", e.toString());
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
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }
}
