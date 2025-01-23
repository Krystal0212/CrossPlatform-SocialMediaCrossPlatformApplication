import 'package:just_audio/just_audio.dart';
import 'package:socialapp/utils/import.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

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
  String? recordingPath;
  bool isPlaying = false;
  bool isSeeking = false; // Flag to handle seeking
  double _sliderValue = 0.0;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    _audioRecorder.dispose();
    audioPlayer.dispose();
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 400,
                alignment: Alignment.center,
                child: CircularIconButton(
                  onPressed: () async {
                    if (isListening) {
                      String? filePath = await _audioRecorder.stop();
                      if (filePath != null) {
                        setState(() {
                          recordingPath = filePath;
                        });
                        await audioPlayer.setFilePath(recordingPath!);
                        isRecording.value = false;
                      }
                    } else {
                      if (await _audioRecorder.hasPermission()) {
                        final Directory appDocumentDir =
                            await getApplicationDocumentsDirectory();
                        final String appDocumentsPath =
                            p.join(appDocumentDir.path, "recording.wav");
                        await _audioRecorder.start(const RecordConfig(),
                            path: appDocumentsPath);
                        // setState(() {
                        //   recordingPath = appDocumentsPath;
                        // });
                        isRecording.value = true;
                      }
                    }
                  },
                  icon: Icon(
                    !isListening ? Icons.mic_rounded : Icons.square,
                    size: 250,
                  ),
                ),
              ),
              if (recordingPath == null) const Text("No recording found. :("),
              SizedBox(
                height: widget.topicBoxHeight * 0.3,
                child: Column(
                  children: [
                    if (recordingPath != null)
                      StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            const position = Duration.zero;
                            final duration = audioPlayer.duration;

                            if (!isSeeking) {
                              _sliderValue = position.inSeconds.toDouble();
                            }

                            return Column(
                              children: [
                                Slider(
                                  value: _sliderValue,
                                  min: 0.0,
                                  max: duration!.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _sliderValue = value;
                                      isSeeking = true;
                                    });
                                    // Seek to the new position
                                    audioPlayer.seek(
                                        Duration(milliseconds: value.toInt()));
                                  },
                                  onChangeEnd: (value) {
                                    setState(() {
                                      isSeeking = false;
                                    });
                                  },
                                ),
                                Text(
                                  "${position.toString().split('.').first} / ${duration.toString().split('.').first}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox.shrink();
                          }

                        },
                      ),
                    if (recordingPath != null)
                      SizedBox(
                        width: widget.topicBoxWidth * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularIconButton(
                              onPressed: () async {
                                if (audioPlayer.playing) {
                                  await audioPlayer.stop();
                                  setState(() {
                                    isPlaying = false;
                                  });
                                } else {
                                  setState(() {
                                    isPlaying = true;
                                  });
                                }
                              },
                              icon: Icon(
                                !isPlaying ? Icons.play_arrow : Icons.pause,
                                size: 55,
                              ),
                            ),
                            CircularIconButton(
                                onPressed: () async {
                                  setState(() {
                                    recordingPath = null;
                                  });

                                },
                                icon: const Icon(
                                  Icons.replay,
                                  size: 55,
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
