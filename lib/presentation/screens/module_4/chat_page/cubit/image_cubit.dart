import 'package:socialapp/utils/import.dart';

enum ImageSendStatus { initial, loading, success, failure }

class ImageSendCubit extends Cubit<ImageSendStatus> {
  ImageSendCubit() : super(ImageSendStatus.initial);

  void sendImageInProgress() => emit(ImageSendStatus.loading);

  void sendImageSuccess() => emit(ImageSendStatus.success);

  void sendImageFailure() => emit(ImageSendStatus.failure);
}
