import 'package:socialapp/utils/import.dart';
import 'dart:ui' as ui;
import 'edit_page_state.dart';

enum UpdateState { failed, success , tagNameTaken}

class EditPageCubit extends Cubit<EditPageState>
    with FlashMessage, ClassificationMixin, ImageAndVideoProcessingHelper {
  bool _isImagePickerActive = false;

  EditPageCubit() : super(EditPageInitial()) {
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    // emit(EditPageLoading());
    try {
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getCurrentUserData();
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
      await context
          .read<AuthRepository>()
          .reAuthenticationAndChangeEmail(email, newEmail, password)
          .then((_) {
        emit(EditPageLoaded(updatedUser.copyWith(newEmail: newEmail)));
      });
    } catch (e) {
      emit(EditPageError('Re-authentication failed. Email not updated.'));
    }
  }

  void pickImagesByMobile(
    ValueNotifier<Map<String, dynamic>> selectedAvatarNotifier,
    BuildContext context,
  ) async {
    if (_isImagePickerActive) {
      return;
    }
    _isImagePickerActive = true;


    try {
      final ImagePicker picker = ImagePicker();
      XFile? image;

      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.white,
            title: Text("Choose an option", style: AppTheme.newPostTitleStyle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.of(context).pop("camera");
                  },
                ),
                ListTile(
                  title: const Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop("gallery");
                  },
                ),
              ],
            ),
          );
        },
      );

      if (choice == null) return;

      if (choice == "camera") {
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          image = pickedFile;
        }
      } else if (choice == "gallery") {
        final XFile? pickedFiles =
            await picker.pickImage(source: ImageSource.gallery);
        image = pickedFiles;
      }

      if (image == null) return;
      selectedAvatarNotifier.value = {...selectedAvatarNotifier.value, 'isLoading': true};

      Uint8List resizedWebP =
          await resizeAndConvertToWebPForMobile(File(image.path));
      ui.Image decodedImage = await decodeImageFromList(resizedWebP);
      int imageWidth = decodedImage.width;
      int imageHeight = decodedImage.height;

      bool isNSFW = await classifyNSFW(resizedWebP);

      Map<String, dynamic> uploadedAvatar = {
        'localImageData': File(image.path).readAsBytesSync(),
        'isNSFW': isNSFW,
        'width': imageWidth,
        'height': imageHeight,
        'isLoading': false,
      };

      selectedAvatarNotifier.value = uploadedAvatar;
    } catch (error) {
      if (kDebugMode) {
        print("Error during pick image: $error");
      }
    } finally {
      _isImagePickerActive = false; // Always reset here
    }
  }

  Future<UpdateState> updateCurrentUserData( UserModel updatedUser,
  UserModel previousUserData, Uint8List? newAvatar) async {
    try {
      bool isUpdated = await serviceLocator<UserRepository>().updateCurrentUserData(
          updatedUser, previousUserData, newAvatar);

      if(isUpdated){
        return UpdateState.success;
      }else{
        return UpdateState.failed;
      }

    } catch (error){
      if (error is CustomFirestoreException && error.code == 'tag-name-taken') {
        return UpdateState.tagNameTaken;
      }
      if (kDebugMode) {
        print("Error during update user data: $error");
      }
      return UpdateState.failed;
    }
  }
}
