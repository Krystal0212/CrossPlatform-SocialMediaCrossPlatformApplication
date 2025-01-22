import 'package:flutter_sound/flutter_sound.dart';
import 'package:socialapp/utils/import.dart';
import '../../../../widgets/general/nsfw_and_close_icons.dart';
import '../../../../widgets/play_video/video_player.dart';
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

  const MobileDialogBody({
    super.key,
    required this.avatarSize,
    required this.styleableTextFieldController,
    required this.imagePathNotifier,
    required this.topicSelectedNotifier,
  });

  @override
  State<MobileDialogBody> createState() => _MobileDialogBodyState();
}

class _MobileDialogBodyState extends State<MobileDialogBody> with FlashMessage {
  late FlutterSoundRecorder _recorder;
  late double deviceWidth, deviceHeight, previewImageHeight;
  late String avatarUrl = "", username = "";
  late List<TopicModel> topics = [];

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();

    _recorder = FlutterSoundRecorder();
  }

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

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
    } else {
      await _recorder.startRecorder(toFile: 'audio.aac');
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: const Text("Voice Recording")),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: _isRecording
                    ? IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: _toggleRecording,
                        iconSize: 60,
                        color: Colors.red,
                      )
                    : IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: _toggleRecording,
                        iconSize: 60,
                        color: Colors.blue,
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                _isRecording ? "Recording..." : "Tap to Record",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_isRecording) const SizedBox(height: 20),
              if (_isRecording) const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
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
                            padding: const EdgeInsets.only(right: 20),
                            child: isVideo
                                ? VideoPlayerPreviewWidget(
                                    videoData: assetData,
                                    height: previewImageHeight,
                                    width: imagePathList[index]['width'] *
                                        previewImageHeight /
                                        imagePathList[index]['height'],
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
                                widget.imagePathNotifier.value = updatedList;
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
    );
  }
}
