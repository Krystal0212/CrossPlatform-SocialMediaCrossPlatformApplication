import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialapp/domain/repository/auth/auth_repository.dart';

import '../../../service_locator.dart';
import '../../sources/auth/auth_firebase_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    return await serviceLocator<AuthFirebaseService>()
        .signInWithEmailAndPassword(email,password);
  }

  @override
  bool isUserVerified() {
    return serviceLocator<AuthFirebaseService>().isUserVerified();
  }

  @override
  bool isSignedIn() {
    return serviceLocator<AuthFirebaseService>().isSignedIn();
  }

  @override
  Future<void> signUp(
    String email,
    String password,
  ) async {
    return await serviceLocator<AuthFirebaseService>().signUp(email, password);
  }

  @override
  Future<void> signInWithGoogle() async {
    return await serviceLocator<AuthFirebaseService>().signInWithGoogle();
  }

  @override
  Future<User?> getCurrentUser() async {
    return serviceLocator<AuthFirebaseService>().getCurrentUser();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return await serviceLocator<AuthFirebaseService>()
        .sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    return await serviceLocator<AuthFirebaseService>().signOut();
  }

  @override
  Future<void> reAuthenticationAndChangeEmail(
      String email, String newEmail, String password) async {
    return await serviceLocator<AuthFirebaseService>()
        .reAuthenticationAndChangeEmail(email, newEmail, password);
  }

  @override
  Future<void> updateCurrentUserAvatarUrl(String avatarUrl) async {
    return await serviceLocator<AuthFirebaseService>()
        .updateAvatarUrl(avatarUrl);
  }

  @override
  Future<void> verifyAccountByOTPLink(String encryptedLink) async {
    return await serviceLocator<AuthFirebaseService>()
        .verifyAccountByOTPLink(encryptedLink);
  }

  @override
  Future<void> verifyAccountByOTPCode(String otpCode) async {
    return await serviceLocator<AuthFirebaseService>()
        .verifyAccountByOTPCode(otpCode);
  }

  @override
  Future<String> verifyResetPasswordRequestByOTPLink(
      String encryptedLink) async {
    return await serviceLocator<AuthFirebaseService>()
        .verifyResetPasswordRequestByOTPLink(encryptedLink);
  }

  @override
  Future<void> sendForCurrentUserVerificationEmail() async {
    return await serviceLocator<AuthFirebaseService>()
        .sendForCurrentUserVerificationEmail();
  }

  @override
  Future<void> resetPassword(String password, String userId) async {
    return await serviceLocator<AuthFirebaseService>()
        .resetPassword(password, userId);
  }



  @override
  bool isCurrentUserGoogleUserWithoutPassword() {
    return serviceLocator<AuthFirebaseService>().isCurrentUserGoogleUserWithoutPassword();
  }

  @override
  Future<void> setPasswordForGoogleUser(String newPassword) async{
    return await serviceLocator<AuthFirebaseService>().setPasswordForGoogleUser(newPassword);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async{
    return await serviceLocator<AuthFirebaseService>().changePassword(currentPassword, newPassword);
  }
}
