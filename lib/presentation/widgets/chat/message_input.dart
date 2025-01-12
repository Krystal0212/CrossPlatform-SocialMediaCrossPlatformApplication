import 'package:socialapp/utils/import.dart';

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.messageController,
    required this.selectedImageNotifier,
    required this.sendMessage,
    required this.sendImageWithText,
    required this.pickImage,
  });

  final TextEditingController messageController;
  final ValueNotifier<XFile?> selectedImageNotifier;
  final VoidCallback sendMessage;
  final VoidCallback sendImageWithText;
  final VoidCallback pickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<XFile?>(
          // This is now correctly isolated
          valueListenable: selectedImageNotifier,
          builder: (context, selectedImage, child) {
            if (selectedImage != null) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(selectedImage.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        selectedImageNotifier.value = null;
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        Padding(
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
                onPressed: pickImage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
