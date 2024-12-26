import 'package:flutter/material.dart';
import 'package:socialapp/presentation/screens/new_post/cubit/post_cubit.dart';
import 'package:socialapp/presentation/screens/new_post/widgets/action_post.dart';
import 'package:socialapp/presentation/screens/new_post/widgets/header_new_post.dart';
import 'package:socialapp/presentation/screens/new_post/widgets/post_content.dart';
import 'package:socialapp/utils/styles/colors.dart';
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
    print('initState cubit post');
    super.initState();
    _postCubit = PostCubit();
  }

  @override
  void dispose() {
    print('dispose cubit post');
    _postCubit.close();
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