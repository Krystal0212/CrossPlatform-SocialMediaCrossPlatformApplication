import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:socialapp/data/repository/auth/auth_repository_impl.dart';
import 'package:socialapp/data/sources/auth/auth_firebase_service.dart';
import 'package:socialapp/data/sources/firestore/firestore_service.dart';
import 'package:socialapp/service_locator.dart';

import '../../../../domain/repository/auth/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthRepository authRepository = AuthRepositoryImpl();

  AuthCubit() : super(AuthInitial()) {
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    try {
      User? user = serviceLocator<AuthFirebaseService>().getCurrentUser();
      if (user != null) {
        if (!user.emailVerified) {
          emit(Unauthenticated());
        }
        await serviceLocator<FirestoreService>().getCurrentUserData();
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      if (e is CustomFirestoreException) {
        emit(Unauthenticated());
      } else {
        emit(Unauthenticated());
        if (kDebugMode) {
          print("Error: $e");
        }
      }
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    emit(Unauthenticated());
  }
}
