import 'package:flutter/material.dart';
import 'package:socialapp/config/app_routes.dart';
import 'package:socialapp/utils/styles/colors.dart';

import 'cubit/post_cubit.dart';
import 'widgets/action_post.dart';
import 'widgets/header_new_post.dart';
import 'widgets/post_content.dart';
// import 'package:socialapp/presentation/screens/post_detail/post_detail/post_detail.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  late PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _postCubit = PostCubit();
  }

  @override
  void dispose() {
    // context.read<PostCubit>().cancelConnectivityListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const Column(
              children: [
                HeaderNewPost(),
                Expanded(
                  child: PostContent()
                ),
              ],
            ),
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: Center(
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.lavenderBlueShadow,
                  ),
                  child: const ActionPost(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}