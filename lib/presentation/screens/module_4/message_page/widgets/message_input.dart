import 'package:socialapp/utils/import.dart';

import '../cubit/image_cubit.dart';
import 'chat_page_properties.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier;
  final String receiverUserID;

  const MessageInput({
    super.key,
    required this.messageController,
    required this.selectedAssetsNotifier,
    required this.receiverUserID,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12.0, right: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black, // Shadow color
            offset: const Offset(0, 1), // Offset in the negative Y direction
            blurRadius: 2, // How much the shadow is blurred
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: TextField(
                cursorColor: AppColors.iris,
                controller: messageController,
                obscureText: false,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Your message',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_upward, size: 40, color: AppTheme.black),
            onPressed: () {
              bool isUser1 = ChatPageUserProperty.of(context);
              if (selectedAssetsNotifier.value.isNotEmpty) {
                context
                    .read<ChatSendCubit>()
                    .sendImageWithText(isUser1,
                    selectedAssetsNotifier, messageController, receiverUserID);
              } else {
                context
                    .read<ChatSendCubit>()
                    .sendMessage(isUser1, messageController, receiverUserID);
              }
            },
          ),
          const SizedBox(width: 6.0),
          IconButton(
            icon: Icon(Icons.image, size: 40, color: AppTheme.black),
            onPressed: () => context.read<ChatSendCubit>().pickImage(selectedAssetsNotifier),
          ),
        ],
      ),
    );
  }
}
