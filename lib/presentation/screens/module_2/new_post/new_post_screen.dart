

import 'package:socialapp/utils/import.dart';

import 'cubit/post_cubit.dart';
import 'widgets/action_post.dart';
import 'widgets/header_new_post.dart';
import 'widgets/post_content.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCubit(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              const Column(
                children: [
                  HeaderNewPost(),
                  PostContent(),
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
      ),
    );
  }
}