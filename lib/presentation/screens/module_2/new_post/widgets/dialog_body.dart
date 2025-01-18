import 'package:flutter_sound/flutter_sound.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:socialapp/utils/import.dart';
import 'package:universal_html/html.dart' as html;
import 'styleable_text_field_controller.dart';
import 'video_player.dart';

class DialogBody extends StatefulWidget {
  final double avatarSize, insertBoxWidth;
  final String avatarUrl, username;

  const DialogBody({
    super.key,
    required this.avatarSize,
    required this.avatarUrl,
    required this.username,
    required this.insertBoxWidth,
  });

  @override
  State<DialogBody> createState() => _DialogBodyState();
}

class _DialogBodyState extends State<DialogBody> {
  late FlutterSoundRecorder _recorder;
  late double deviceWidth, deviceHeight;

  late final TextEditingController textEditingController;
  late final ClassificationModel classificationModel;

  bool _isRecording = false;
  bool _isModelReady = false;
  late bool isWeb;

  final ValueNotifier<int> maxLinesNotifier = ValueNotifier<int>(2);
  final ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final double textFieldHeightFactor = 0.3;

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

    if(kIsWeb) {
      initNSFWModel();
    }
  }

  Future<void> initNSFWModel() async {
    try {
      classificationModel = await PytorchLite.loadClassificationModel(
        "assets/models/nsfw-model.pt", 224, 224, 5,
        labelPath: "assets/labels/labels_nsfw.txt",
      );
      print("Model finished");
        _isModelReady = true;
    } catch (e) {
      if (kDebugMode) {
        print('Model initialization error $e');
      }
        _isModelReady = false;
    }
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
  }

  void _updateMaxLines(double fieldWidth, String text) {
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

  void _uploadImages() async {
    // Create a file input element
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*,video/*'; // Accept images and videos
    uploadInput.multiple = true; // Allow multiple file selection

    // Trigger file selection dialog
    uploadInput.click();

    if (kDebugMode) {
      print("Pick the files");
    }

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;

      if (files != null && files.isNotEmpty) {
        final List<Map<String, dynamic>> uploadedFiles = [];
        for (var file in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;
          final Map<String, dynamic> uploadedAsset = {};
          late double imageRatio = 0.5;

          if (file.type.startsWith('image')) {
            final String imgUrl = html.Url.createObjectUrl(file);
            final html.ImageElement imageElement = html.ImageElement();
            imageElement.src = imgUrl;

            imageElement.onLoad.listen((_) {
              int width = imageElement.width ?? 0;
              int height = imageElement.height ?? 1;
              imageRatio = width / height;
            });

            uploadedAsset['type'] = 'image';
          } else if (file.type.startsWith('video')) {
            final String videoUrl = await _getLocalVideoUrl(file);
            final Map<String, double> videoDimensions =
                await _getVideoDimensions(videoUrl);

            final double width = videoDimensions['width'] ?? 0;
            final double height = videoDimensions['height'] ?? 1;

            imageRatio = width / height;
            uploadedAsset['type'] = 'video';
          }

          uploadedAsset['ratio'] = imageRatio;
          uploadedAsset['data'] = reader.result as Uint8List;
          uploadedAsset['isNSFW'] = await _isNSFWAsset(uploadedAsset['data']);

          print('isNSFW ${uploadedAsset['isNSFW']}');

          uploadedFiles.add(uploadedAsset);
        }

        imagePathNotifier.value = uploadedFiles;
      }
    });
  }

  Future<bool> _isNSFWAsset(Uint8List image) async {
    if (image.isEmpty || kIsWeb) return false;

    try {
      List<double>? imagePrediction = await classificationModel
          .getImagePredictionListProbabilities(image,
              mean: [0.5, 0.5, 0.5], std: [0.5, 0.5, 0.5]);

      if (imagePrediction.isNotEmpty) {
        List<String> labels = [
          "drawings",
          "hentai",
          "neutral",
          "porn",
          "sexy"
        ];
        List<String> nsfwLabels = ["hentai", "porn", "sexy"];

        String label = '';
        double maxValue = 0;
        for (int i = 0; i < labels.length; i++) {
          double percentage = imagePrediction[i] * 100;
          if (percentage > maxValue) {
            maxValue = percentage;
            label = labels[i];
          }
        }


        if (nsfwLabels.contains(label)) {
          return true;
        }
      }
          return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error during classification: $e");
      }
      return false;
    }
  }

  Future<Map<String, double>> _getVideoDimensions(String videoUrl) async {
    final completer = Completer<Map<String, double>>();
    final videoElement = html.VideoElement()
      ..src = videoUrl
      ..preload = 'metadata';
    videoElement.onLoadedMetadata.listen((_) {
      final double width = videoElement.getBoundingClientRect().width.toDouble();
      final double height = videoElement.getBoundingClientRect().height.toDouble();

      completer.complete({'width': width, 'height': height});
    });
    videoElement.onError.listen((_) {
      completer.completeError('Failed to load video metadata');
    });
    return completer.future;
  }

  Future<String> _getLocalVideoUrl(html.File file) async {
    final completer = Completer<String>();
    String url = html.Url.createObjectUrl(file);
    completer.complete(url);
    return completer.future;
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
              backgroundImage: CachedNetworkImageProvider(widget.avatarUrl,
                  maxWidth: 25, maxHeight: 25),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.username, style: AppTheme.blackUsernameStyle),
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
                                  minLines: 2,
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
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: imagePathNotifier,
                builder: (context, imagePathList, child) {
                  if (imagePathList.isNotEmpty) {
                    final bool isSingle = imagePathList.length == 1;
                    final bool isLandscape = imagePathList[0]['ratio'] > 1;

                    // Single item and landscape
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
                onPressed: () => _uploadImages(),
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
