import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialapp/data/models/auth/create_user_req.dart';
import 'package:socialapp/data/models/auth/sign_in_user_req.dart';

abstract class AuthRepository {
  bool isUserVerified();

  bool isSignedIn();

  Future<void> signUp(SignUpUserReq signUpUserReq);

  Future<void> signInWithEmailAndPassword(SignInUserReq signInUserReq);

  Future<void> signInWithGoogle();

  Future<User?> getCurrentUser();

  Future<void> signOut();

  Future<void> reAuthenticationAndChangeEmail(
      String email, String newEmail, String password);

  Future<void> updateCurrentUserAvatarUrl(String avatarUrl);

  Future<void> verifyAccountByOTPLink(String encryptedLink);

  Future<String> verifyResetPasswordRequestByOTPLink(String encryptedLink);

  Future<void> verifyAccountByOTPCode(String otpCode);

  Future<void> sendForCurrentUserVerificationEmail();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> resetPassword(String password, String userId);
}
