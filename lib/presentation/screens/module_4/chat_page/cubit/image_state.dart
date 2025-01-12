import '../../../../../utils/import.dart';

abstract class ImageCubitState {}

class ImageInitial extends ImageCubitState {}

class ImageLoading extends ImageCubitState {}

class ImagePicked extends ImageCubitState {
  final XFile image;

  ImagePicked({required this.image});
}

class ImageSending extends ImageCubitState {}

class ImageSent extends ImageCubitState {}

class ImageError extends ImageCubitState {
  final String message;

  ImageError({required this.message});
}
