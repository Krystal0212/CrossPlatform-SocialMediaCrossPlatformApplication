import 'package:socialapp/utils/import.dart';

import '../cubit/image_cubit.dart';

class ImageSendStatusWidget extends StatefulWidget {
  final ScrollController scrollController;

  const ImageSendStatusWidget({
    super.key, required this.scrollController,
  });

  @override
  State<ImageSendStatusWidget> createState() => _ImageSendStatusWidgetState();
}

class _ImageSendStatusWidgetState extends State<ImageSendStatusWidget> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageSendCubit, ImageSendStatus>(
      listener: (context, state) {
        if (state == ImageSendStatus.loading) {
          _showSnackBar('Uploading image...', AppColors.corona);
        } else if (state == ImageSendStatus.success) {
          _scrollToBottom();
          _showSnackBar('Image sent successfully!', AppColors.monstrousGreen);
        } else if (state == ImageSendStatus.failure) {
          _showSnackBar(
              'Failed to send image, please try again', AppColors.pelati);
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      final position = scrollController.position.minScrollExtent;
      scrollController.animateTo(
        position,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

}
