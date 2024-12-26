// import '../../../../domain/repository/user/user.dart';
import 'package:socialapp/utils/import.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());

  void reset() {
    emit(SignInInitial()); // Reset to initial state
  }

  void loginWithEmailAndPassword(BuildContext context,
      GlobalKey<FormState> formKey, SignInUserReq signInUserReq) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(SignInLoading());
        await serviceLocator<AuthRepository>()
            .signInWithEmailAndPassword(signInUserReq);
        await serviceLocator<UserRepository>().getCurrentUserData();
        emit(SignInSuccess());

        if(context.mounted) {
        context.go('/home');}
      }
    } catch (e) {
      if (e is CustomFirestoreException) {
        if (e.code == 'new-user') {
          emit(SignInSuccess());
        }
      }else if (e is FirebaseAuthException) {
        if (e.code == 'email-not-verified') {
          emit(SignInFailure());
          if (context.mounted) {
            context.go('/verify', extra: {"state": 1});
          }
        }
      } else {
        emit(SignInFailure());
        if (context.mounted) {
          _showAlertDialog(context, AppStrings.authError, e.toString());
        }
      }
    }
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      await serviceLocator<AuthRepository>().signInWithGoogle();
      await serviceLocator<UserRepository>().getCurrentUserData();
      emit(SignInSuccess());
    } catch (e) {
      if (e is CustomFirestoreException) {
        if (e.code == 'new-user') {

          emit(SignInSuccess());
          if(context.mounted){
            context.go('/home');
          }
        }
      } else if (e is FirebaseAuthException) {
        if (e.code == 'email-not-verified') {
          emit(SignInFailure());
          if (context.mounted) {
            context.go('/verify', extra: {"state": 1});
          }
        }
      } else {
        emit(SignInFailure());
        throw Exception(e);
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
