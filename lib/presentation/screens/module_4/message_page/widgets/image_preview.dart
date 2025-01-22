import 'package:socialapp/presentation/screens/module_2/new_post/widgets/mobile_dialog_body.dart';
import 'package:socialapp/presentation/widgets/play_video/video_player.dart';
import 'package:socialapp/utils/import.dart';

import '../../../../widgets/general/nsfw_and_close_icons.dart';

class ImagePreview extends StatelessWidget {
  final ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier;
  final ScrollController scrollController;

  const ImagePreview({
    super.key,
    required this.selectedAssetsNotifier,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: selectedAssetsNotifier,
      builder: (context, imagePathList, child) {
        if (imagePathList.isNotEmpty) {
          return Positioned(
            bottom: MediaQuery.of(context).size.height * 0.08,
            left: 16.0,
            right: 16.0,
            child: SizedBox(
              width: deviceWidth * 0.8,
              height: 250,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePathList.length,
                  itemBuilder: (context, index) {
                    return ImagePreviewDisplay(
                      selectedAssetsNotifier: selectedAssetsNotifier,
                      index: index,
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class ImagePreviewDisplay extends StatefulWidget {
  final int index;
  final ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier;

  const ImagePreviewDisplay({
    super.key,
    required this.selectedAssetsNotifier,
    required this.index,
  });

  @override
  State<ImagePreviewDisplay> createState() => _ImagePreviewDisplayState();
}

class _ImagePreviewDisplayState extends State<ImagePreviewDisplay> {
  final ValueNotifier<bool> _isImageLoadedNotifier = ValueNotifier<bool>(false);

  late double deviceWidth;
  late final List imagePathList;
  late final Uint8List assetData;

  @override
  void initState() {
    super.initState();

    imagePathList = widget.selectedAssetsNotifier.value;
    assetData = imagePathList[widget.index]['data'];
  }

  @override
  void dispose() {
    _isImageLoadedNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final List imagePathList = widget.selectedAssetsNotifier.value;
    final Uint8List assetData = imagePathList[widget.index]['data'];

    return SizedBox(
      width: deviceWidth * 0.32,
      child: Stack(
        children: [
          // ImageSendStatusWidget(
          //   scrollController: scrollController,
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: imagePathList[widget.index]['type'] == 'video'
                ? VideoPlayerPreviewWidget(videoData: assetData, height: 250, width:250*imagePathList[widget.index]['width']/imagePathList[widget.index]['height'])
                : Container(
                    height: 250,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 15.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        assetData,
                        fit: BoxFit.cover,
                        frameBuilder: (BuildContext context, Widget child,
                            int? frame, bool wasSynchronouslyLoaded) {
                          if (frame != null || wasSynchronouslyLoaded) {
                            // Defer the update to the ValueNotifier after the current frame is rendered
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_isImageLoadedNotifier.value) {
                                _isImageLoadedNotifier.value = true;
                              }
                            });
                          }
                          return child;
                        },
                      ),
                    ),
                  ),
          ),
          if (imagePathList[widget.index]['isNSFW'])
          Positioned(
            left: 10,
            child: SizedBox(width: 40,child: Image.asset(AppIcons.nsfw,fit: BoxFit.fitWidth,)),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isImageLoadedNotifier,
            builder: (context, isImageLoaded, child) {
              if (!isImageLoaded) return const SizedBox.shrink();

              return Positioned(
                top: 10,
                right: 30,
                child: CloseIconButton(
                  onTap: () {
                    final List<Map<String, dynamic>> updatedList =
                        List<Map<String, dynamic>>.from(imagePathList);
                    updatedList.removeAt(widget.index);
                    widget.selectedAssetsNotifier.value = updatedList;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
