import 'package:socialapp/data/repository/storage/storate_repository_impl.dart';
import 'package:socialapp/domain/repository/storage/storage_repository.dart';
import 'package:socialapp/utils/import.dart';

import 'edit_page_state.dart';

class EditPageCubit extends Cubit<EditPageState> {
  final AuthRepository authRepository = AuthRepositoryImpl();
  final UserRepository userRepository = UserRepositoryImpl();
  final StorageRepository storageRepository = StorageRepositoryImpl();

  EditPageCubit() : super(EditPageInitial()) {
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    // emit(EditPageLoading());
    try {
      final UserModel? userModel = await serviceLocator<UserRepository>().getCurrentUserData();
      if (userModel != null) {
        emit(EditPageLoaded(userModel));
      } else {
        emit(EditPageError("User data not found"));
      }
    } catch (e) {
      emit(EditPageError(e.toString()));
    }
  }

  Future<void> reAuthenticateAndChangeEmail(
      BuildContext context,
      UserModel updatedUser,
      String newEmail,
      String email,
      String password) async {
    emit(EditPageLoading());
    try {
      if (kDebugMode) {
        print("Changing.....");
      }
      await authRepository
          .reAuthenticationAndChangeEmail(email, newEmail, password)
          .then((_) {
        emit(EditPageLoaded(updatedUser.copyWith(newEmail: newEmail)));
      });
    } catch (e) {
      emit(EditPageError('Re-authentication failed. Email not updated.'));
    }
  }

// Future<void> uploadAvatar(XFile image, String userId) async {
//   emit(EditPageLoading());
//
//   try {
//     storageRepository.uploadAvatar(image, userId);
//
//     emit(EditPageLoaded(updatedUser));
//   } catch (e) {
//     emit(EditPageError('Failed to upload avatar'));
//   }
// }

// Future<void> updateAvatarInFirestore(String userId, String avatarUrl) async {
//   // Code to update avatar URL in Firestore
// }
}
