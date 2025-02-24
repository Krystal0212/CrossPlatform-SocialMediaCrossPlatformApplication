// import '../../../../domain/repository/user/user.dart';
import 'package:socialapp/utils/import.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial()) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final bool isUserVerified =
          serviceLocator<AuthRepository>().isUserVerified();
      final bool isSignedIn = serviceLocator<AuthRepository>().isSignedIn();

      if (isSignedIn) {
        if (isUserVerified) {
          final UserModel? currentUser =
              await serviceLocator<UserRepository>().getCurrentUserData();
          if (currentUser == null) {
            emit(SignInSuccessButNotPickTopics());
          }
          emit(SignInSuccessProcessCompleted());
        } else {
          emit(SignInSuccessButNotVerified());
        }
      }
    } catch (e) {
      if (e is CustomFirestoreException) {
        if (e.code == 'new-user') {
          emit(SignInSuccessButNotPickTopics());
        }
      }
    }
  }

  void loginWithEmailAndPassword(
      BuildContext context, GlobalKey<FormState> formKey,
      {required String email, required String password}) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(SignInLoading());
        await serviceLocator<AuthRepository>()
            .signInWithEmailAndPassword(email, password);
        UserModel? currentUser =
            await serviceLocator<UserRepository>().getCurrentUserData();
        if (currentUser != null) {
          if (!context.mounted) return;

          context.go('/home');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      if (e is CustomFirestoreException) {
        if (e.code == 'new-user') {
          if (!context.mounted) return;
          context.go('/preferred-topic');
          emit(SignInSuccess());
        }
      } else if (e is FirebaseAuthException) {
        if (e.code == 'email-not-verified') {
          emit(SignInFailure());
          if (context.mounted) {
            context.go('/verify', extra: {"isFromSignIn": true});
          }
        }
      } else {
        emit(SignInFailure());
        if (context.mounted) {
          _showAlertDialog(context, AppStrings.authError,
              'Invalid password or email. Try again later');
        }
      }
    }
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      await serviceLocator<AuthRepository>().signInWithGoogle();
      UserModel? currentUser =
      await serviceLocator<UserRepository>().getCurrentUserData();
      if (currentUser != null) {
        if (!context.mounted) return;

        context.go('/home');
      }
    } catch (e) {
      if (e is CustomFirestoreException) {
        if (e.code == 'new-user') {
          emit(SignInSuccess());
          if (!context.mounted) return;
          context.go('/preferred-topic');
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
