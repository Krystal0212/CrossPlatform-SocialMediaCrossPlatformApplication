import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:socialapp/utils/import.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

const double optionIconSize = 50;
const double recordBoxWidth = 100;

enum RecordState { start, init, complete }

enum PlayerState { reset, play, pause, complete }

class RecordBox extends StatefulWidget {
  final double topicBoxWidth, topicBoxHeight;
  final ValueNotifier<String?> recordingPathNotifier;


  const RecordBox({
    super.key,
    required this.topicBoxWidth,
    required this.topicBoxHeight, required this.recordingPathNotifier,
  });

  @override
  State<RecordBox> createState() => _RecordBoxState();
}

class _RecordBoxState extends State<RecordBox> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ValueNotifier<RecordState> isRecording =
      ValueNotifier<RecordState>(RecordState.init);
  final ValueNotifier<PlayerState> isPlayingNotifier =
      ValueNotifier<PlayerState>(PlayerState.reset);
  final ValueNotifier<double> sliderValueNotifier = ValueNotifier<double>(0.0);

  final PlayerController _playerController = PlayerController();
  Timer? _timer;
  int _secondsElapsed = 0; // Track elapsed seconds

  @override
  void initState() {
    super.initState();

    _playerController.onCompletion.listen((event) {
      isPlayingNotifier.value = PlayerState.complete;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _playerController.dispose();
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory appDocumentDir = await getApplicationDocumentsDirectory();
      final String appDocumentsPath =
          p.join(appDocumentDir.path, "recording.wav");
      await _audioRecorder.start(const RecordConfig(), path: appDocumentsPath);
      isRecording.value = RecordState.start;
      widget.recordingPathNotifier.value = appDocumentsPath;

      // Start the timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });
    }
  }

  void _stopRecording() async {
    String? filePath = await _audioRecorder.stop();
    if (filePath != null) {
      widget.recordingPathNotifier.value = filePath;
      _playerController.preparePlayer(path: filePath);
      isRecording.value = RecordState.complete;
    }
    _timer?.cancel();
    _secondsElapsed = 0;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.topicBoxWidth,
      height: widget.topicBoxHeight,
      alignment: Alignment.center,
      child: ValueListenableBuilder<RecordState>(
        valueListenable: isRecording,
        builder: (context, isListening, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isListening != RecordState.complete)
                (isListening == RecordState.init)
                    ? CircularIconButton(
                        onPressed: () async {
                          _startRecording();
                        },
                        icon: const Icon(
                          Icons.mic_rounded,
                          size: 150,
                        ),
                        backgroundColor: AppColors.cabbageBlossomViolet,
                      )
                    : CircularTextButton(
                        onPressed: () async {
                          _stopRecording();
                        },
                        text: Text(
                          _formatTime(_secondsElapsed),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white),
                        ),
                        boxWidth: 150,
                      ),
              if (isListening == RecordState.init)
                Text("Tap to start recording your voice =)))",
                    style: AppTheme.blackHeaderStyle),
              if (isListening == RecordState.start)
                Text("Tap the counter to stop recording",
                    style: AppTheme.blackHeaderStyle),

              if (isListening == RecordState.complete)
              // Recording status and controls
              ValueListenableBuilder<String?>(
                valueListenable: widget.recordingPathNotifier,
                builder: (context, recordingPath, _) {
                  return Container(
                    decoration: AppTheme.mainVerticalGradientBoxDecoration,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AudioFileWaveforms(
                          size: Size(widget.topicBoxWidth * 0.9, 50),
                          playerController: _playerController,
                          waveformType: WaveformType.fitWidth,
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ValueListenableBuilder<PlayerState>(
                              valueListenable: isPlayingNotifier,
                              builder: (context, playerState, _) {
                                if (playerState == PlayerState.complete) {
                                  return CircularIconButton(
                                    onPressed: () async {
                                      _playerController.stopPlayer();
                                      _playerController.preparePlayer(
                                          path: recordingPath!);

                                      isPlayingNotifier.value =
                                          PlayerState.reset;
                                      _playerController.seekTo(0);
                                    },
                                    icon: const Icon(
                                      Icons.replay,
                                      size: optionIconSize,
                                    ),
                                    style: AppTheme.recordButtonStyle,
                                    boxWidth: recordBoxWidth,
                                    backgroundColor: Colors.transparent,
                                  );
                                } else if (playerState == PlayerState.play) {
                                  return CircularIconButton(
                                    onPressed: () async {
                                      _playerController.pausePlayer();
                                      isPlayingNotifier.value =
                                          PlayerState.pause;
                                    },
                                    icon: const Icon(
                                      Icons.pause,
                                      size: optionIconSize,
                                    ),
                                    style: AppTheme.recordButtonStyle,
                                    boxWidth: recordBoxWidth,
                                    backgroundColor: Colors.transparent,
                                  );
                                } else if (playerState == PlayerState.pause) {
                                  return CircularIconButton(
                                    onPressed: () async {
                                      _playerController.startPlayer();
                                      isPlayingNotifier.value =
                                          PlayerState.play;
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: optionIconSize,
                                    ),
                                    style: AppTheme.recordButtonStyle,
                                    boxWidth: recordBoxWidth,
                                    backgroundColor: Colors.transparent,
                                  );
                                } else {
                                  return CircularIconButton(
                                    onPressed: () async {
                                      _playerController.startPlayer();
                                      isPlayingNotifier.value =
                                          PlayerState.play;
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: optionIconSize,
                                    ),
                                    style: AppTheme.recordButtonStyle,
                                    boxWidth: recordBoxWidth,
                                    backgroundColor: Colors.transparent,
                                  );
                                }
                              },
                            ),
                            CircularIconButton(
                              onPressed: () async {
                                // Delete the recording and reset the UI
                                widget.recordingPathNotifier.value = null;
                                isPlayingNotifier.value = PlayerState.reset;
                                isRecording.value = RecordState.init;
                                sliderValueNotifier.value = 0.0;
                              },
                              icon: const Icon(
                                Icons.delete_forever_rounded,
                                size: optionIconSize,
                              ),
                              style: AppTheme.recordButtonStyle,
                              boxWidth: recordBoxWidth,
                              backgroundColor: Colors.transparent,
                            ),
                          ],
                        ),
                      ],
                    ),
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
