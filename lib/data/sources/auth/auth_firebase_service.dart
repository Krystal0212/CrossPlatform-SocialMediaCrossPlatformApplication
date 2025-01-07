import 'package:socialapp/utils/import.dart';
import "package:http/http.dart";

abstract class AuthFirebaseService {
  Future<void> signUp(SignUpUserReq signUpUserReq);

  Future<void> signInWithEmailAndPassword(SignInUserReq signInUserReq);

  bool isUserVerified();

  Future<void> signInWithGoogle();

  Future<void> verifyAccountByOTPLink(String encryptedLink);

  Future<void> verifyAccountByOTPCode(String otpCode);

  Future<void> verifyResetPasswordRequestByOTPLink(String encryptedLink);

  Future<void> sendForCurrentUserVerificationEmail();

  Future<void> sendPasswordResetEmail(String recipientEmail);

  Future<void> resetPassword(String recipientEmail);

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

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
        );
      }

      if (!user.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Your email address has not been verified. Please verify your email before proceeding.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("${AppStrings.firebaseAuthError}: ${e.toString()}");
      }
      switch (e.code) {
        case 'email-not-verified':
          rethrow;
        case 'user-not-found':
          throw (AppStrings.userNotFoundError);
        case 'wrong-password':
          throw (AppStrings.incorrectEmailOrPasswordError);
        case 'invalid-credential':
          throw (AppStrings.incorrectEmailOrPasswordError);
        default:
          throw ("${e.message}");
      }
    } catch (error) {
      if (kDebugMode) {
        print("${AppStrings.authenticationUnknownError}: ${error.toString()}");
      }
      rethrow;
    }
  }

  @override
  bool isUserVerified() {
    try {
      User? user = getCurrentUser();

      if (user == null) {
        return false;
      } else if (!user.emailVerified) {
        return false;
      }

      return true;
    } catch (error) {
      if (kDebugMode) {
        print("${AppStrings.authenticationUnknownError}: ${error.toString()}");
      }
      return false;
    }
  }

  @override
  Future<void> signUp(SignUpUserReq signUpUserReq) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: signUpUserReq.email,
        password: signUpUserReq.password,
      );

      final accessToken = await userCredential.user?.getIdToken() ?? "";

      sendVerificationEmail(signUpUserReq.email, accessToken);

      await userCredential.user!.updatePhotoURL(AppStrings.defaultAvatarUrl);
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

  String generateOtp() {
    final random = Random();
    // Generate a random 6-digit number
    int otp = 100000 + random.nextInt(900000); // Ensures a 6-digit number
    return otp.toString();
  }

  @override
  Future<void> sendForCurrentUserVerificationEmail() async {
    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }
      String recipientEmail = _auth.currentUser?.email ?? '';
      String accessToken = await _auth.currentUser?.getIdToken() ?? '';

      if (recipientEmail.isEmpty) {
        throw 'Failed to retrieve user email';
      }

      if (accessToken.isEmpty) {
        throw 'Failed to retrieve access token';
      }

      sendVerificationEmail(recipientEmail, accessToken);
    } catch (error) {
      if (kDebugMode) {
        print('Verification failed: $error');
      }
      rethrow;
    }
  }

  Future<void> sendVerificationEmail(
      String recipientEmail, String accessToken) async {
    final Uri url =
        Uri.parse('https://api-m2ogw2ba2a-uc.a.run.app/sendEmailWithOTP');
    final String otpCode = generateOtp();

    try {
      final response = await post(
        url,
        headers: {
          // "auth-token": accessToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipientEmail': recipientEmail,
          'otpCode': otpCode,
          'verificationLink': 'zineround.site/#/verify?code='
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Email sent successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to send email: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error sending email: $error');
      }
    }
  }

  @override
  Future<void> verifyAccountByOTPLink(String encryptedLink) async {
    final url =
        Uri.parse('https://api-m2ogw2ba2a-uc.a.run.app//verifyOTPByLink');

    String newEncryptedLink = encryptedLink.trim();
    try {
      final response = await get(url.replace(queryParameters: {
        'encryptedLink': newEncryptedLink,
      }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        throw response.body;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Verification failed: $error');
      }
      rethrow;
    }
  }

  @override
  Future<void> verifyAccountByOTPCode(String otpCode) async {
    final url =
        Uri.parse('https://api-m2ogw2ba2a-uc.a.run.app//verifyOTPByCode');

    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }

      final response = await get(url.replace(queryParameters: {
        'otpCode': otpCode,
        'userLoggedEmail': _auth.currentUser?.email
      }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        throw response.body;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Verification failed: $error');
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
  Future<void> sendPasswordResetEmail(String recipientEmail) async {
    final Uri url =
        Uri.parse('https://api-m2ogw2ba2a-uc.a.run.app/sendEmailResetPassword');
    final String otpCode = generateOtp();
    try {
      // use a post function from url of send reset email deployed on cloud functions
      // final url = Uri.parse('https://api-m2ogw2ba2a-uc.a.run.app//sendEmailResetPassword');
      final response = await post(
        url,
        headers: {
          // "auth-token": accessToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipientEmail': recipientEmail,
          'otpCode': otpCode,
          'verificationLink': 'zineround.site/#/reset-password?code='
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Email sent successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to send email: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("${AppStrings.authenticationError} : ${error.toString()}");
      }

      rethrow;
    }
  }

  @override
  Future<void> verifyResetPasswordRequestByOTPLink(String encryptedLink) async {
    // Create Cloud functions first before parsing URLs
    final url = Uri.parse(
        'https://api-m2ogw2ba2a-uc.a.run.app//verifyResetPasswordLink');
    try {
      final response = await get(url.replace(queryParameters: {
        'encryptedLink': encryptedLink.trim(),
      }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        throw response.body;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Verification failed: $error');
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

  @override
  Future<void> resetPassword(String recipientEmail) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
