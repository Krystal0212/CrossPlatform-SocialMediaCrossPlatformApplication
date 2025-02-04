import 'package:socialapp/utils/import.dart';

import '../cubit/post_detail_cubit.dart';

class PostDetailEditTextField extends StatefulWidget {
  final OnlinePostModel post;
  final ValueNotifier<int> commentAmountNotifier;

  const PostDetailEditTextField({super.key, required this.post, required this.commentAmountNotifier});

  @override
  State<PostDetailEditTextField> createState() =>
      _PostDetailEditTextFieldState();
}

class _PostDetailEditTextFieldState extends State<PostDetailEditTextField> {
  final TextEditingController _commentTextFieldController = TextEditingController();
  final ValueNotifier<bool> _canSendNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _commentTextFieldController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _commentTextFieldController.removeListener(_onTextChanged);
    _commentTextFieldController.dispose();
    _canSendNotifier.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _canSendNotifier.value = _commentTextFieldController.text.trim().isNotEmpty;
  }

  void _sendComment() {
    if (_canSendNotifier.value) {
      context.read<PostDetailCubit>().sendComment(widget.post.userId, _commentTextFieldController.text.trim());
      widget.commentAmountNotifier.value =  widget.commentAmountNotifier.value + 1;
      _commentTextFieldController.clear();
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth * 0.9;
          return Container(
            decoration: AppTheme.commentBoxDecoration,
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentTextFieldController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    maxLength: 800,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _canSendNotifier,
                  builder: (context, canSend, child) {
                    return AnimatedOpacity(
                      opacity: canSend ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.iris),
                        onPressed: canSend ? _sendComment : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}