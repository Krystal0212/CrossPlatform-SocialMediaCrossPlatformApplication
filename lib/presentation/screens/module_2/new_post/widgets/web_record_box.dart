import 'package:just_audio/just_audio.dart';
import 'package:socialapp/utils/import.dart';
import 'package:record/record.dart';
import 'package:universal_html/html.dart' as html;
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
  dispose() {
    _audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String? filePath) async {
    if (filePath == null) return;

    if (kIsWeb) {
      final ByteData bytes = await rootBundle.load(filePath);
      final List<int> byteArray = bytes.buffer.asUint8List();
      final blob = html.Blob([Uint8List.fromList(byteArray)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      await audioPlayer.setUrl(url);
    } else {
      await audioPlayer.setFilePath(filePath);
    }

    await audioPlayer.play();
    setState(() {
      isPlaying = true;
    });
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
            children: [
              if (recordingPath != null)
                MaterialButton(
                  onPressed: () async {
                    if (audioPlayer.playing) {
                      await audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await _playAudio(recordingPath);
                    }
                  },
                  child: Text(
                    isPlaying ? "Stop playing recording" : "Start playing recording",
                  ),
                ),
              if (recordingPath == null)
                const Text("No recording found. :("),
              // Your CircularIconButton for start/stop recording
              SizedBox(
                width: 100,
                height: 100,
                child: CircularIconButton(
                  onPressed: () async {
                    if (isListening) {
                      String? filePath = await _audioRecorder.stop();
                      if (filePath != null) {
                        setState(() {
                          recordingPath = filePath;
                        });
                        isRecording.value = false;
                      }
                    } else {
                      if (await _audioRecorder.hasPermission()) {
                        if (kIsWeb) {
                          const String tempPath = "recording_temp.wav";
                          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.pcm16bits),
                              path: tempPath);
                          setState(() {
                            recordingPath = tempPath; // Dummy path for web
                          });
                        } else {
                          final Directory appDocumentDir = await getApplicationDocumentsDirectory();
                          final String appDocumentsPath = p.join(appDocumentDir.path, "recording.wav");
                          await _audioRecorder.start(const RecordConfig(), path: appDocumentsPath);
                          setState(() {
                            recordingPath = appDocumentsPath;
                          });
                        }
                        isRecording.value = true;
                      }
                    }
                  },
                  icon: Icon(!isListening ? Icons.mic_rounded : Icons.mic_off_rounded),
                ),
              ),
              // Slider to show and adjust the audio playback position
              if (recordingPath != null && isPlaying)
                Column(
                  children: [
                    StreamBuilder<Duration>(
                      stream: audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = audioPlayer.duration ?? Duration.zero;

                        // Update slider value only when not seeking
                        if (!isSeeking) {
                          _sliderValue = position.inMilliseconds.toDouble();
                        }

                        return Column(
                          children: [
                            Slider(
                              value: _sliderValue,
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  _sliderValue = value;
                                  isSeeking = true;
                                });
                                // Seek to the new position
                                audioPlayer.seek(Duration(milliseconds: value.toInt()));
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
                      },
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}