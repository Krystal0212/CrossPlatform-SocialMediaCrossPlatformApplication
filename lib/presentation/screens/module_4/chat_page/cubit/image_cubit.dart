import 'package:socialapp/utils/import.dart';
import '../../../../../data/sources/chat/chat_service.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageCubitState> {
  final ImagePicker _picker;

  ImageCubit()
      : _picker = ImagePicker(),
        super(ImageInitial());

  Future<void> pickImage() async {
    try {
      emit(ImageLoading());
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        emit(ImagePicked(image: pickedImage));
      } else {
        emit(ImageInitial()); // No image selected
      }
    } catch (e) {
      emit(ImageError(message: "Failed to pick image: $e"));
    }
  }

  Future<void> sendImage(String receiverUserId, String messageText,
      ChatService chatService) async {
    final currentState = state;
    if (currentState is ImagePicked) {
      try {
        emit(ImageSending());
        await chatService.sendImageMessage(
          receiverUserId,
          currentState.image.path,
          messageText,
        );
        emit(ImageSent());
      } catch (e) {
        emit(ImageError(message: "Failed to send image: $e"));
      }
    }
  }

  void reset() {
    emit(ImageInitial());
  }
}
