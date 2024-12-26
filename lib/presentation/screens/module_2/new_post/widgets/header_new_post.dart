import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/data/sources/firestore/firestore_service.dart';
import 'package:socialapp/service_locator.dart';
import 'package:socialapp/utils/styles/colors.dart';

import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';

class HeaderNewPost extends StatefulWidget {
  const HeaderNewPost({super.key});

  @override
  State<HeaderNewPost> createState() => _HeaderNewPostState();
}

class _HeaderNewPostState extends State<HeaderNewPost> {
  late PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _postCubit = context.read<PostCubit>();
  }

  Future _uploadPost() async {
    PostState state = _postCubit.state;
    File? image;
    String? content;

    if (state is PostWithData) {
      // print('image: ${state.getImage}');
      image = state.getImage;
      content = state.getContent;
      content ??= '';
    }

    if (image != null) {
      print('image: $image');
      print('content: $content');
      await serviceLocator<FirestoreService>().createPost(content!, image);
    }

    _postCubit.closeNewPost();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppColors.lavenderBlueShadow,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,  
            children: [
              IconButton(
                onPressed: () {
                  _postCubit.closeNewPost();
                },
                icon: const Icon(Icons.arrow_back, color: AppColors.white,),
              ),
              
              TextButton(
                onPressed: () {
                  _uploadPost();
                },
                child: const Text('Post', style: TextStyle(color: AppColors.white,),),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              child: Center(
                child: Text(
                  'Create post'.toUpperCase(),
                  style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
              ),
            )
            ),
        ] 
      ),
    );
  }
}