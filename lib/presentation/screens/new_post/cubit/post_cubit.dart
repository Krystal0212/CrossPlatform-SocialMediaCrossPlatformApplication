import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/new_post/cubit/post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitial());

  void createImagePost(File image, {String caption = ''}) {
    // print('check');
    // print('image: $image');
    emit(PostWithImage(image, caption));
  }

  void closeNewPost() {
    emit(const PostInitial());
  }

  void updateContent(String? content) {
    final currentState = state;
    if (currentState is PostWithData) {
      emit(currentState.copyWith(content: content));
    } else {
      emit(PostWithData(content: content));
    }
  }

  // Method to update the image
  void updateImage(File? image) {
    final currentState = state;
    if (currentState is PostWithData) {
      emit(currentState.copyWith(image: image));
    } else {
      emit(PostWithData(image: image));
    }
  }

  // Submission logic ensuring an image is required
  void submitPost() {
    final currentState = state;
    if (currentState is PostWithData) {
      final image = currentState.image;
      final content = currentState.content;

      if (image == null) {
        print("You must provide an image to create a post.");
      } else {
        // Perform submission logic (e.g., send to server)
        print("Content: ${content ?? 'No content'}");
        print("Image: ${image.path}");
      }
    } else {
      print("You must provide an image to create a post.");
    }
  }
}