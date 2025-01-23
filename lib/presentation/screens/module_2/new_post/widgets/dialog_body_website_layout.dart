import 'package:socialapp/presentation/screens/module_2/new_post/widgets/record_box.dart';
import 'package:socialapp/utils/import.dart';
import '../cubit/new_post_cubit.dart';
import '../providers/new_post_properties_provider.dart';
import 'dialog_body_box.dart';
import 'styleable_text_field_controller.dart';
import '../../../../widgets/play_video/video_player_preview.dart';

class WebsiteDialogBody extends StatefulWidget {
  final double avatarSize, insertBoxWidth, topicBoxWidth;

  const WebsiteDialogBody({
    super.key,
    required this.avatarSize,
    required this.insertBoxWidth,
    required this.topicBoxWidth,
  });

  @override
  State<WebsiteDialogBody> createState() => _WebsiteDialogBodyState();
}

class _WebsiteDialogBodyState extends State<WebsiteDialogBody>
    with FlashMessage {
  late double deviceWidth, deviceHeight, previewImageHeight;
  late int maxLine, minLine, maxLineMicro;
  late String avatarUrl = "", username = "";

  late final TextEditingController styleableTextFieldController;
  late final ValueNotifier<bool> isRecordingMode = ValueNotifier<bool>(false);

  late bool isWeb;

  final ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier =
      ValueNotifier<List<TopicModel>>([]);

  final double textFieldHeightFactor = 0.4;

  @override
  void initState() {
    super.initState();

    styleableTextFieldController = StyleableTextFieldController(
      styles: TextPartStyleDefinitions(
        definitionList: <TextPartStyleDefinition>[
          TextPartStyleDefinition(
            style: AppTheme.highlightedHashtagStyle,
            pattern: r'(#[a-zA-Z0-9_]+)',
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    username = NewPostPropertiesProvider.of(context)!.user!.name;
    avatarUrl = NewPostPropertiesProvider.of(context)!.user!.avatar;

    if (NewPostPropertiesProvider.of(context)!.isCompactView!) {
      previewImageHeight = 150;
      maxLine = 1;
      minLine = 1;
    } else {
      previewImageHeight = 250;
      maxLine = 4;
      minLine = 2;
    }
  }

  @override
  void dispose() {
    styleableTextFieldController.dispose();
    imagePathNotifier.dispose();
    topicSelectedNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!NewPostPropertiesProvider.of(context)!.isCompactView!)
            SizedBox(
              width: widget.avatarSize,
              height: widget.avatarSize,
              child: CircleAvatar(
                radius: 10,
                backgroundImage: CachedNetworkImageProvider(avatarUrl,
                    maxWidth: 25, maxHeight: 25),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: AppTheme.blackUsernameStyle),
              SizedBox(
                width: widget.insertBoxWidth,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 0.1,
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: deviceHeight * textFieldHeightFactor,
                        ),
                        child: SingleChildScrollView(
                          child: TextField(
                            autocorrect: false,
                            enableSuggestions: true,
                            maxLines: maxLine,
                            minLines: minLine,
                            controller: styleableTextFieldController,
                            textAlign: TextAlign.start,
                            decoration: AppTheme.whiteInputDecoration,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (NewPostPropertiesProvider.of(context)?.isCompactView ?? false)
                WebsiteDialogActionBox(
                  topicBoxWidth: widget.topicBoxWidth,
                  topicSelectedNotifier: topicSelectedNotifier,
                  topicBoxHeight: 20,
                ),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: imagePathNotifier,
                builder: (context, imagePathList, child) {
                  if (imagePathList.isNotEmpty) {
                    // List of items
                    return SizedBox(
                      height: previewImageHeight,
                      width: widget.insertBoxWidth,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePathList.length,
                        itemBuilder: (context, index) {
                          final Uint8List assetData =
                          imagePathList[index]['data'];
                          final bool isVideo = imagePathList[index]['type'] == 'video';

                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: isVideo
                                    ? VideoPlayerPreviewWidget(
                                  videoData: assetData,
                                  height: previewImageHeight,
                                  width: imagePathList[index]['width']*previewImageHeight/imagePathList[index]['height'],
                                )
                                    : Container(
                                  height: previewImageHeight,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    border:
                                    Border.all(color: Colors.grey),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: Image.memory(
                                      assetData,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              if (imagePathList[index]['isNSFW'])
                                Positioned(
                                  top: isVideo? 45:0,
                                  left:  10,
                                  child: SizedBox(
                                      width: 45,
                                      child: Image.asset(
                                        AppIcons.nsfw,
                                        fit: BoxFit.fitWidth,
                                      )),
                                ),
                              Positioned(
                                top: 10,
                                right: 30,
                                child: CloseIconButton(
                                  onTap: () {
                                    final List<Map<String, dynamic>>
                                    updatedList =
                                    List<Map<String, dynamic>>.from(
                                        imagePathList);
                                    updatedList.removeAt(index);
                                    imagePathNotifier.value = updatedList;
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox(); // Return an empty widget if no items are present
                },
              ),
            ],
          ),
          if (!NewPostPropertiesProvider.of(context)!.isCompactView!)
            WebsiteDialogActionBox(
              topicBoxWidth: widget.topicBoxWidth,
              topicSelectedNotifier: topicSelectedNotifier,
              topicBoxHeight: 50,
            ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  context
                      .read<NewPostCubit>()
                      .pickAssetsByWeb(imagePathNotifier, context);
                },
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return AppTheme.mainGradient.createShader(bounds);
                  },
                  child: const Icon(Icons.perm_media_outlined,
                      color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<NewPostCubit>().sendPost(
                      NewPostPropertiesProvider.of(context)!.homeContext!,
                      context,
                      styleableTextFieldController,
                      imagePathNotifier,
                      topicSelectedNotifier);
                },
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return AppTheme.mainGradient.createShader(bounds);
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CloseIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const CloseIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.redDecoration,
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }
}

class NSFWIcon extends StatelessWidget {
  const NSFWIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 10,
      right: 10,
      child: MouseRegion(
        child: Tooltip(
          message: AppStrings.alertNSFW,
          child: CircleAvatar(
            backgroundColor: AppColors.circus,
            radius: 20,
            child: Icon(
              Icons.warning,
              color: AppColors.dynamicBlack,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
