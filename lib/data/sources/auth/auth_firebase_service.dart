import 'package:socialapp/utils/import.dart';

abstract class AuthFirebaseService {
  Future<void> signUp(SignUpUserReq signUpUserReq);

  Future<void> signInWithEmailAndPassword(SignInUserReq signInUserReq);

  Future<void> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  User? getCurrentUser();

  Future<void> signOut();

  Future<void> reAuthenticationAndChangeEmail(
      String email, String newEmail, String password);

  Future<void> updateCurrentUserAvatarUrl(String avatarUrl);

  Future<void> updateAvatarUrl(String avatarUrl);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAuthProvider _googleProvider = GoogleAuthProvider();

  @override
  Future<void> signInWithEmailAndPassword(SignInUserReq signInUserReq) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: signInUserReq.email.trim(),
        password: signInUserReq.password.trim(),
      );

      User? user = userCredential.user;
      // if (kDebugMode) {
      //   print("User signed in : ${user?.email}");
      // }

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
        );
      }

      if (user.emailVerified) {
        await signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("${AppStrings.firebaseAuthError}: ${e.message}");
      }
      switch (e.code) {
        case 'email-not-verified':
          throw (AppStrings.emailNotVerifiedError);
        case 'user-not-found':
          throw (AppStrings.userNotFoundError);
        case 'wrong-password':
            throw(AppStrings.incorrectEmailOrPasswordError);
        case 'invalid-credential':
          throw (AppStrings.incorrectEmailOrPasswordError);
        default:
          throw ("${e.message}");
      }
    } catch (error) {
      if (kDebugMode) {
        print("${AppStrings.authenticationError} : ${error.toString()}");
      }
      rethrow;
    }
  }

  @override
  Future<void> signUp(SignUpUserReq signUpUserReq) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: signUpUserReq.email,
        password: signUpUserReq.password,
      );

      await userCredential.user!.sendEmailVerification();
      await userCredential.user!.updatePhotoURL(AppStrings.defaultAvatarUrl);
      signOut();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("${AppStrings.firebaseAuthError}: ${e.message}");
      }

      if (e.code == 'email-already-in-use') {
        throw (AppStrings.emailExistedError);
      } else {
        throw ("${e.message}");
      }
    } catch (error) {
      if (kDebugMode) {
        print("${AppStrings.authenticationError} : ${error.toString()}");
      }

      rethrow;
    }
  }

    @override
    Future<void> signInWithGoogle() async {
      try {
        UserCredential googleUserCredential;
        if (kIsWeb) {
          googleUserCredential = await _auth.signInWithPopup(_googleProvider);
          // _googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
          // _googleProvider.setCustomParameters({
          //   'login_hint': 'user@example.com'
          // });

        } else {
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          final GoogleSignInAuthentication? googleAuth =
              await googleUser?.authentication;

          // Create a GoogleAuthProvider credential
          final AuthCredential googleCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );

          // Sign in to Firebase with Google credentials
          googleUserCredential =
          await _auth.signInWithCredential(googleCredential);
        }

        User? user = googleUserCredential.user;

        if (user == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
          );
        }

        if (kDebugMode) {
          print("User signed in : ${user.email}");
        }
      } catch (error) {
        if (kDebugMode) {
          print("${AppStrings.authenticationError} : ${error.toString()}");
        }

        rethrow;
      }
    }

    @override
    Future<void> sendPasswordResetEmail(String email) async {
      try {
        final signInMethod = await _auth.fetchSignInMethodsForEmail(email);

        if (signInMethod.isNotEmpty) {
          await _auth.sendPasswordResetEmail(email: email);
        } else {
          throw FirebaseAuthException(
            code: 'email-not-found',
            message: AppStrings.emailNotFoundError,
          );
        }
      } catch (error) {
        if (kDebugMode) {
          print("${AppStrings.authenticationError} : ${error.toString()}");
        }

        rethrow;
      }
    }

    @override
    Future<void> signOut() async {
      await _auth.signOut();
    }

    @override
    User? getCurrentUser() {
      return _auth.currentUser;
    }

    @override
  Future<void> reAuthenticationAndChangeEmail(
        String email, String newEmail, String password) async {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );

          await user
              .reauthenticateWithCredential(credential)
              .then((userCredential) async {
            await userCredential.user?.updateEmail(newEmail);
            await userCredential.user?.reload();
            await userCredential.user?.sendEmailVerification();
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw (AppStrings.emailNotFoundError);
        } else {
          rethrow;
        }
      } catch (error) {
        if (kDebugMode) {
          print("${AppStrings.authenticationError} : ${error.toString()}");
        }

        rethrow;
      }
    }

    @override
  Future<void> updateAvatarUrl(String avatarUrl) async {
      try {
        User? user = _auth.currentUser;

        if (user != null) {
          await user.updatePhotoURL(avatarUrl);

          await user.reload();
        } else {
          throw FirebaseAuthException(code: 'no-user-is-currently-signed-in');
        }
      } catch (e) {
        if (kDebugMode) {
          print("${AppStrings.failedToUpdateAvatarError} : $e");
        }
      }
    }

  @override
  Future<void> updateCurrentUserAvatarUrl(String avatarUrl) {
    // TODO: implement updateCurrentUserAvatarUrl
    throw UnimplementedError();
  }
}
