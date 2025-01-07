import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:universal_html/html.dart' as html;
import 'package:socialapp/utils/import.dart';

import 'widgets/styleable_text_field_controller.dart';

class CreateNewPostDialogContent extends StatefulWidget {
  final UserModel currentUser;

  const CreateNewPostDialogContent({super.key, required this.currentUser});

  @override
  State<CreateNewPostDialogContent> createState() =>
      _CreateNewPostDialogContentState();
}

class _CreateNewPostDialogContentState
    extends State<CreateNewPostDialogContent> {
  final double sideWidth = 25;
  final ValueNotifier<int> maxLinesNotifier = ValueNotifier<int>(2);
  final ValueNotifier<List<Uint8List>> imagePathNotifier =
      ValueNotifier<List<Uint8List>>([]);

  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;

  late double deviceWidth, deviceHeight;
  late bool isCompactView, isMediumView, isLargeView;
  late final TextEditingController textEditingController;

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
      updateMaxLines(deviceWidth * 0.23, textEditingController.text);
    });

    _recorder = FlutterSoundRecorder();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    maxLinesNotifier.dispose();
    imagePathNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    isCompactView = deviceWidth < 680;
    isMediumView = deviceWidth >= 680 && deviceWidth < 1200;
    isLargeView = deviceWidth >= 1200;
  }

  void updateMaxLines(double fieldWidth, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.blackUsernameStyle, // Match TextField's font size
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

    if (newMaxLines < 2) {
      maxLinesNotifier.value = 2;
    } else if (maxLinesNotifier.value != newMaxLines) {
      maxLinesNotifier.value = newMaxLines;
    }
  }

  void uploadImages() async {
    // Create a file input element
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*,video/*'; // Accept images and videos
    uploadInput.multiple = true; // Allow multiple file selection

    // Trigger file selection dialog
    uploadInput.click();

    // Wait for the user to select files
    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final List<Uint8List> uploadedFiles = [];
        for (var file in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;
          uploadedFiles.add(reader.result as Uint8List);
        }
        // Update the ValueNotifier with the selected files
        imagePathNotifier.value = uploadedFiles;
      }
    });
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
                  icon: Icon(Icons.stop),
                  onPressed: _toggleRecording,
                  iconSize: 60,
                  color: Colors.red,
                )
                    : IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _toggleRecording,
                  iconSize: 60,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _isRecording ? "Recording..." : "Tap to Record",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_isRecording) SizedBox(height: 20),
              if (_isRecording)
                CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth * 0.4,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: sideWidth,
                width: sideWidth,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                  child:
                      SvgPicture.asset(AppIcons.cross, width: 18, height: 18),
                ),
              ),
              const Text(
                'Create New Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: sideWidth,
              )
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            color: AppColors.iris,
            thickness: 1,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: CachedNetworkImageProvider(
                        widget.currentUser.avatar,
                        maxWidth: 25,
                        maxHeight: 25),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.currentUser.name,
                        style: AppTheme.blackUsernameStyle),
                    SizedBox(
                      width: (isLargeView)
                          ? deviceWidth * 0.27
                          : deviceWidth * 0.1,
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
                                      maxHeight: deviceHeight * 0.3,
                                    ),
                                    child: SingleChildScrollView(
                                      child: TextField(
                                        autocorrect: false,
                                        enableSuggestions: true,
                                        maxLines: maxLines,
                                        minLines: 2,
                                        controller: textEditingController,
                                        textAlign: TextAlign.start,
                                        decoration:
                                            AppTheme.whiteInputDecoration,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          ValueListenableBuilder<List<Uint8List>>(
                            valueListenable: imagePathNotifier,
                            builder: (context, imagePathList, child) {
                              if (imagePathList.isNotEmpty) {
                                if (kDebugMode) {
                                  print('Images/Videos picked');
                                }
                                return GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // Number of columns
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: imagePathList.length,
                                  itemBuilder: (context, index) {
                                    return Image.memory(
                                      imagePathList[index],
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              }
                              return const Center(child: Text('No images/videos selected.'));
                            },
                          )
                        ],
                      ),
                    ),
                    ValueListenableBuilder<List<Uint8List>>(
                      valueListenable: imagePathNotifier,
                      builder: (context, imagePathList, child) {
                        if (imagePathList.isNotEmpty) {
                          print('images picked');
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Image.memory(
                                imagePathList[0],
                                // Display image from byte data
                                fit: BoxFit.cover,
                                height: 150, // Adjust height as needed
                                width: 150, // Adjust width as needed
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => uploadImages(),
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
                        child:
                            const Icon(Icons.mic_rounded, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
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
          ),
        ],
      ),
    );
  }
}
