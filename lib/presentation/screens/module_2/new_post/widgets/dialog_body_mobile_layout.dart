import 'package:flutter_sound/flutter_sound.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/widgets/record_box.dart';
import 'package:socialapp/utils/import.dart';
import '../../../../widgets/general/nsfw_and_close_icons.dart';
import '../../../../widgets/play_video/video_player_preview.dart';
import '../cubit/new_post_cubit.dart';
import '../providers/new_post_properties_provider.dart';
import 'dialog_body_box.dart';
import 'dialog_topics_selection.dart';
import 'styleable_text_field_controller.dart';

class MobileDialogBody extends StatefulWidget {
  final double avatarSize;
  final TextEditingController styleableTextFieldController;

  final ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier;
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier;
  final ValueNotifier<bool> isRecordingMode;

  const MobileDialogBody({
    super.key,
    required this.avatarSize,
    required this.styleableTextFieldController,
    required this.imagePathNotifier,
    required this.topicSelectedNotifier,
    required this.isRecordingMode,
  });

  @override
  State<MobileDialogBody> createState() => _MobileDialogBodyState();
}

class _MobileDialogBodyState extends State<MobileDialogBody> with FlashMessage {
  late double deviceWidth, deviceHeight, previewImageHeight;
  late String avatarUrl = "", username = "";
  late List<TopicModel> topics = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    username = NewPostPropertiesProvider.of(context)!.user!.name;
    avatarUrl = NewPostPropertiesProvider.of(context)!.user!.avatar;
    previewImageHeight = 250;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: TextField(
                autocorrect: false,
                enableSuggestions: true,
                maxLines: 5,
                minLines: 2,
                controller: widget.styleableTextFieldController,
                textAlign: TextAlign.start,
                decoration: AppTheme.whiteInputDecorationMobile,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: AppTheme.blackHeaderStyle.copyWith(fontSize: 20),
              ),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: widget.isRecordingMode,
              builder: (context, isRecordModeChosen, child) {
                if (!isRecordModeChosen) {
                  return Column(
                    children: [
                      MobileDialogActionBox(
                        topicSelectedNotifier: widget.topicSelectedNotifier,
                      ),
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: widget.imagePathNotifier,
                        builder: (context, imagePathList, child) {
                          if (imagePathList.isNotEmpty) {
                            // List of items
                            return SizedBox(
                              height: previewImageHeight,
                              width: 490,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: imagePathList.length,
                                itemBuilder: (context, index) {
                                  final Uint8List assetData =
                                      imagePathList[index]['data'];
                                  final bool isVideo =
                                      imagePathList[index]['type'] == 'video';

                                  return Stack(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: isVideo
                                            ? VideoPlayerPreviewWidget(
                                                videoData: assetData,
                                                height: previewImageHeight,
                                                width: imagePathList[index]
                                                        ['width'] *
                                                    previewImageHeight /
                                                    imagePathList[index]
                                                        ['height'],
                                              )
                                            : Container(
                                                height: previewImageHeight,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: Colors.grey),
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
                                          top: isVideo ? 45 : 0,
                                          left: 10,
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
                                            widget.imagePathNotifier.value =
                                                updatedList;
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
                  );
                } else {
                  return Container(

                    color: Colors.redAccent,
                    child: const RecordBox(
                      topicBoxWidth: 490,
                      topicBoxHeight: 490,
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
