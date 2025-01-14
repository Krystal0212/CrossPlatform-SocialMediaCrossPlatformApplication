import 'package:socialapp/utils/import.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final ValueNotifier<XFile?> selectedImageNotifier;
  final Function sendMessage;
  final Function sendImageWithText;
  final Function pickImage;

  const MessageInput({
    super.key,
    required this.messageController,
    required this.selectedImageNotifier,
    required this.sendMessage,
    required this.sendImageWithText,
    required this.pickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 8.0, bottom: 8.0),
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
            icon: const Icon(Icons.arrow_upward,
                size: 40, color: AppColors.lightIris),
            onPressed: () {
              if (selectedImageNotifier.value != null) {
                sendImageWithText();
              } else {
                sendMessage();
              }
            },
          ),
          const SizedBox(width: 6.0),
          IconButton(
            icon: const Icon(Icons.image, size: 40, color: AppColors.iris),
            onPressed: ()=>pickImage,
          ),
        ],
      ),
    );
  }
}
