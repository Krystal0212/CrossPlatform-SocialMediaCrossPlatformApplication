import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:socialapp/presentation/screens/module_4/message_list/chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<void> _initFuture;
  late ClassificationModel classificationModel;
  Uint8List? image;
  String? result;

  @override
  void initState() {
    super.initState();
    _initFuture = init();
  }

  Future<void> init() async {
    classificationModel = await PytorchLite.loadClassificationModel(
      "assets/models/nsfw-model.pt",
      224,
      224,
      5,
      labelPath: "assets/labels/labels_nsfw.txt",
    );
  }

  Future<void> pickImage() async {
    final returnImg =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnImg != null) {
      final imageFile = File(returnImg.path).readAsBytesSync();
      setState(() {
        image = imageFile;
      });
      // classifying();
    }
  }

  Future<void> classifying() async {
    if (image == null) return;

    try {
      final resizedImage = resizeImage(image!);
      List<double>? imagePrediction = await classificationModel
          .getImagePredictionListProbabilities(resizedImage,
              mean: [0.5, 0.5, 0.5], std: [0.5, 0.5, 0.5]);

      if (imagePrediction.isNotEmpty) {
        List<String> labels = ["drawings", "hentai", "neutral", "porn", "sexy"];

        String formattedResult = "";
        for (int i = 0; i < labels.length; i++) {
          double percentage = imagePrediction[i] * 100;
          formattedResult +=
              "${labels[i]}: ${percentage.toStringAsFixed(2)}%\n";
        }

        setState(() {
          result = formattedResult;
        });
      } else {
        setState(() {
          result = "Unable to classify the image.";
        });
      }
    } catch (e) {
      debugPrint("Error during classification: $e");
    }
  }

  Uint8List resizeImage(Uint8List imageData) {
    final image = img.decodeImage(imageData);
    final resized = img.copyResize(image!, width: 224, height: 224);
    return Uint8List.fromList(img.encodeJpg(resized));
  }

  Future<void> sendImageToServer() async {
    if (image == null) return;

    try {
      final resizedImage = resizeImage(image!);
      final uri = Uri.parse(
          'https://fastapi-cloud-function-351093878135.us-central1.run.app/classify/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        resizedImage,
        filename: 'image.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] as Map<String, dynamic>;

        String formattedResult = "";
        result.forEach((label, percentage) {
          formattedResult += "$label: ${percentage.toStringAsFixed(2)}%\n";
        });

        setState(() {
          this.result = formattedResult;
        });
      } else {
        setState(() {
          result = "Failed to classify image. Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      debugPrint("Error during sending image: $e");
      setState(() {
        result = "An error occurred while sending the image.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Image Classifier"),
          backgroundColor: Colors.cyan,
        ),
        body: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error loading model: ${snapshot.error}"),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (image != null)
                    Image.memory(
                      image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  else
                    const Text("No image selected"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text(
                      "Select Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: classifying,
                    child: const Text(
                      "Classify Locally",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: sendImageToServer,
                    child: const Text(
                      "Send to Server",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Result:"),
                  const SizedBox(height: 8),
                  if (result != null)
                    Text(
                      result!,
                      textAlign: TextAlign.center,
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MessageList()));
                    },
                    child: const Text(
                      "Chat cho vui",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
