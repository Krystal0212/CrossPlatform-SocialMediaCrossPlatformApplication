import 'package:socialapp/utils/import.dart';
import 'dart:ui' as ui;

import 'profile_box_state.dart';

class ProfileBoxCubit extends Cubit<ProfileBoxState>
    with FlashMessage, ClassificationMixin, ImageAndVideoProcessingHelper {

  ProfileBoxCubit() : super(ProfileBoxInitial()) {
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    emit(ProfileBoxLoading());
    try {
      final User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();

      if (currentUser != null) {
        final UserModel? userModel =
        await serviceLocator<UserRepository>().getCurrentUserData();
        emit(ProfileBoxLoaded(userModel!));
      } else {
        emit(ProfileBoxError("User data not found"));
      }
    } catch (e) {
      if(kDebugMode){
        print("Error loading current user data: $e");
      }
      emit(ProfileBoxError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    super.close();
    emit(ProfileBoxInitial());
  }
}
