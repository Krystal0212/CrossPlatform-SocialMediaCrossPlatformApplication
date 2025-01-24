import 'package:just_audio/just_audio.dart';
import 'package:socialapp/utils/import.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

const double optionIconSize = 75;

class RecordBox extends StatefulWidget {
  final double topicBoxWidth, topicBoxHeight;

  const RecordBox({
    super.key,
    required this.topicBoxWidth,
    required this.topicBoxHeight,
  });

  @override
  State<RecordBox> createState() => _RecordBoxState();
}

class _RecordBoxState extends State<RecordBox> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> recordingPathNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<double> sliderValueNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        final position = _audioPlayer.position;
        final duration = _audioPlayer.duration ?? Duration.zero;

        // Only reset if the position matches the duration (playback finished)
        if (position >= duration && duration > Duration.zero) {
          isPlayingNotifier.value = false;
        }
      }
    });

    // Listen to position changes for slider updates
    _audioPlayer.positionStream.listen((position) {
      final duration = _audioPlayer.duration ?? Duration.zero;
      if (duration > Duration.zero) {
        sliderValueNotifier.value = position.inSeconds.toDouble();
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.topicBoxWidth,
      height: widget.topicBoxHeight,
      alignment: Alignment.center,
      child: ValueListenableBuilder<bool>(
        valueListenable: isRecording,
        builder: (context, isListening, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Recording button
              CircularIconButton(
                onPressed: () async {
                  if (isListening) {
                    String? filePath = await _audioRecorder.stop();
                    if (filePath != null) {
                      recordingPathNotifier.value = filePath;
                      await _audioPlayer.setFilePath(filePath);
                      isRecording.value = false;
                    }
                  } else {
                    if (await _audioRecorder.hasPermission()) {
                      final Directory appDocumentDir = await getApplicationDocumentsDirectory();
                      final String appDocumentsPath = p.join(appDocumentDir.path, "recording.wav");
                      await _audioRecorder.start(const RecordConfig(), path: appDocumentsPath);
                      isRecording.value = true;
                    }
                  }
                },
                icon: const Icon(
                  Icons.mic_rounded,
                  size: 150,
                ),
              ),

              // Recording status and controls
              ValueListenableBuilder<String?>(
                valueListenable: recordingPathNotifier,
                builder: (context, recordingPath, _) {
                  if (recordingPath == null) {
                    return const Text("No recording found. :(");
                  }

                  return Column(
                    children: [
                      // Slider

                      ValueListenableBuilder<double>(
                        valueListenable: sliderValueNotifier,
                        builder: (context, sliderValue, _) {
                          final duration = _audioPlayer.duration ?? Duration.zero;
                          return Slider(
                            value: sliderValue,
                            min: 0.0,
                            max: duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              _audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40,),

                      // Play, Pause, and Delete Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: isPlayingNotifier,
                            builder: (context, isPlaying, _) {
                              final position = _audioPlayer.position;
                              final duration = _audioPlayer.duration ?? Duration.zero;
                              final canReset = position >= duration && duration > Duration.zero;

                              // Show refresh icon if audio is finished
                              if (canReset) {
                                return CircularIconButton(
                                  onPressed: () async {
                                    _audioPlayer.stop();
                                    setState(() {
                                      isPlayingNotifier.value = false;  // Force rebuild using setState
                                    });
                                    await _audioPlayer.seek(Duration.zero);

                                  },
                                  icon: const Icon(
                                    Icons.replay,
                                    size: optionIconSize,
                                  ),
                                );
                              }

                              // Show play/pause icons based on isPlaying state
                              return CircularIconButton(
                                onPressed: () async {
                                  if (isPlaying) {
                                    await _audioPlayer.pause();
                                    // Temporarily set to true
                                    isPlayingNotifier.value = true;
                                    isPlayingNotifier.value = false;
                                  } else {
                                    isPlayingNotifier.value = true;
                                    await _audioPlayer.play();
                                  }
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: optionIconSize,
                                ),
                              );
                            },
                          ),
                          CircularIconButton(
                            onPressed: () async {
                              // Delete the recording and reset the UI
                              recordingPathNotifier.value = null; // Set recordingPath to null
                              isPlayingNotifier.value = false;
                              sliderValueNotifier.value = 0.0;
                            },
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              size: optionIconSize,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}