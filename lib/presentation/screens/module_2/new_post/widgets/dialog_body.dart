import 'package:flutter_sound/flutter_sound.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/providers/new_post_properties_provider.dart';
import 'package:socialapp/utils/import.dart';
import '../cubit/new_post_cubit.dart';
import 'styleable_text_field_controller.dart';
import 'video_player.dart';

class DialogBody extends StatefulWidget {
  final double avatarSize, insertBoxWidth;

  const DialogBody({
    super.key,
    required this.avatarSize,
    required this.insertBoxWidth,
  });

  @override
  State<DialogBody> createState() => _DialogBodyState();
}

class _DialogBodyState extends State<DialogBody> {
  late FlutterSoundRecorder _recorder;
  late double deviceWidth, deviceHeight;
  late String avatarUrl = "", username = "";

  late final TextEditingController textEditingController;

  bool _isRecording = false;
  late bool isWeb;

  final ValueNotifier<int> maxLinesNotifier = ValueNotifier<int>(4);
  final ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final double textFieldHeightFactor = 0.4;

  @override
  void initState() {
    super.initState();

    textEditingController = StyleableTextFieldController(
      styles: TextPartStyleDefinitions(
        definitionList: <TextPartStyleDefinition>[
          TextPartStyleDefinition(
            style: AppTheme.highlightedHashtagStyle,
            pattern: r'(#[a-zA-Z0-9_]+)',
          ),
        ],
      ),
    );

    textEditingController.addListener(() {
      _updateMaxLines(deviceWidth * 0.23, textEditingController.text);
    });

    _recorder = FlutterSoundRecorder();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    username = NewPostPropertiesProvider.of(context)!.user!.name;
    avatarUrl = NewPostPropertiesProvider.of(context)!.user!.avatar;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    maxLinesNotifier.dispose();
    imagePathNotifier.dispose();
    super.dispose();
  }

  void _updateMaxLines(double fieldWidth, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.blackUsernameStyle,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final int newMaxLines = (textPainter.size.width / fieldWidth).ceil();

    if (text.contains('\n')) {
      if (kDebugMode) {
        print('T $text');
      }
    }

    if (newMaxLines < 4) {
      maxLinesNotifier.value = 4;
    } else if (maxLinesNotifier.value != newMaxLines) {
      maxLinesNotifier.value = newMaxLines;
    }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      child: ValueListenableBuilder<int>(
                          valueListenable: maxLinesNotifier,
                          builder: (context, maxLines, child) {
                            return Container(
                              constraints: BoxConstraints(
                                maxHeight: deviceHeight * textFieldHeightFactor,
                              ),
                              child: SingleChildScrollView(
                                child: TextField(
                                  autocorrect: false,
                                  enableSuggestions: true,
                                  maxLines: maxLines,
                                  minLines: 4,
                                  controller: textEditingController,
                                  textAlign: TextAlign.start,
                                  decoration: AppTheme.whiteInputDecoration,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: imagePathNotifier,
                builder: (context, imagePathList, child) {
                  if (imagePathList.isNotEmpty) {
                    final bool isSingle = imagePathList.length == 1;
                    final bool isLandscape = imagePathList[0]['ratio'] > 1;

                    if (isSingle && isLandscape) {
                      final Uint8List assetData = imagePathList[0]['data'];
                      return SizedBox(
                        width: deviceWidth * 0.32,
                        child: Stack(
                          children: [
                            imagePathList[0]['type'] == 'video'
                                ? VideoPlayerWidget(videoData: assetData)
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.trolleyGrey),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        assetData,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: CloseIconButton(
                                onTap: () {
                                  final List<Map<String, dynamic>> updatedList =
                                      List<Map<String, dynamic>>.from(
                                          imagePathList);
                                  updatedList.removeAt(0);
                                  imagePathNotifier.value = updatedList;
                                },
                              ),
                            ),
                            if (imagePathList[0]['isNSFW'])
                              const Positioned(
                                top: 10,
                                right: 10,
                                child: NSFWIcon(),
                              ),
                          ],
                        ),
                      );
                    }

                    // List of items
                    return SizedBox(
                      height: 250,
                      width: deviceWidth * 0.32,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePathList.length,
                        itemBuilder: (context, index) {
                          final Uint8List assetData =
                              imagePathList[index]['data'];

                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: imagePathList[index]['type'] == 'video'
                                    ? VideoPlayerWidget(videoData: assetData)
                                    : Container(
                                        height: 250,
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
                                  left: 10,
                                  child: SizedBox(width: 45,child: Image.asset(AppIcons.nsfw,fit: BoxFit.fitWidth,)),
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
          Column(
            children: [
              IconButton(
                onPressed: () =>
                    context.read<NewPostCubit>().pickAssets(imagePathNotifier),
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return AppTheme.mainGradient.createShader(bounds);
                  },
                  child: const Icon(Icons.perm_media_outlined,
                      color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => _showRecordingDialog(context),
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return AppTheme.mainGradient.createShader(bounds);
                  },
                  child: const Icon(Icons.mic_rounded, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => context.read<NewPostCubit>().sendPost(textEditingController, imagePathNotifier),
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
