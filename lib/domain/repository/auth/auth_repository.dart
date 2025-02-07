import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  bool isUserVerified();

  bool isSignedIn();

  Future<void> signUp(String email, String password);

  Future<void> signInWithEmailAndPassword(String email, String password);

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

  bool isCurrentUserGoogleUserWithoutPassword();

  Future<void> setPasswordForGoogleUser(String newPassword);

  Future<void> changePassword(String currentPassword, String newPassword);
}
