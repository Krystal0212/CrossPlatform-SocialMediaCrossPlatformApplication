import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/new_post/cubit/post_cubit.dart';
import 'package:socialapp/presentation/screens/new_post/cubit/post_state.dart';

class PostContent extends StatefulWidget {
  const PostContent({super.key});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  late PostCubit _postCubit;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _postCubit = context.read<PostCubit>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onTapOutside: (e) {
                FocusManager.instance.primaryFocus?.unfocus();
              }, 
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
              ),
              onChanged: (value) {
                // _postCubit.createPost(content: value);
                print(value);
                _postCubit.updateContent(value.isEmpty ? null : value);
              },
              textInputAction: TextInputAction.done,
            ),
            BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostWithData) {
                  if (state.getImage != null) {
                    // return Image.file(
                    //   state.getImage!,
                    //   width: MediaQuery.of(context).size.width * 0.8,
                    //   fit: BoxFit.contain,
                    // );
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: Image.file(
                        state.getImage!,
                        fit: BoxFit.contain,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}