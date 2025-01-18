import 'dart:ui';

import 'package:socialapp/utils/import.dart';
import 'package:image/image.dart' as img;

class ChatService extends ChangeNotifier {
  // get instance of auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  String get currentUserId => currentUser?.uid ?? '';

  String get currentUserEmail => currentUser?.email.toString() ?? '';

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  // ToDo: Service Functions
  String _getChatRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort(); // Sort ids to ensure chatRoomId is the same for every pair of chatter
    return ids.join("_");
  }

  // Send message
  Future<void> sendMessage(
      bool isUser1, String receiverId, String message) async {
    final Timestamp timestamp = Timestamp.now();

    try {
      if (currentUserId.isNotEmpty && currentUserEmail.isNotEmpty) {
        ChatMessageModel newMessage = ChatMessageModel(
          isFromUser1: isUser1,
          message: message,
          timestamp: timestamp,
        );

        String chatRoomId = _getChatRoomId(currentUserId, receiverId);

        // Add new message to database
        await _firestoreDB
            .collection("ChatRoom")
            .doc(chatRoomId)
            .collection("messages")
            .add(newMessage.toMap());
      } else {
        throw CustomFirestoreException(
            code: "no-user-data", message: 'The current user is not found');
      }
    } on CustomFirestoreException catch (error) {
      if (kDebugMode) {
        print('${error.code} : ${error.message}');
      }
    }
  }

  // Get message for chat room
  Stream<QuerySnapshot> getMessages(String receiverId) {
    final String currentUserId = currentUser?.uid ?? '';
    try {
      String chatRoomId = _getChatRoomId(currentUserId, receiverId);

      return _firestoreDB
          .collection("ChatRoom")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .snapshots();
    } catch (error) {
      if (kDebugMode) {
        print('Error while retrieving message : $error');
      }
      return const Stream.empty();
    }
  }

  Future<Uint8List?> _compressImage(String imagePath) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      imagePath,
      format: CompressFormat.webp, // Compress to WebP
      quality: 80,
    );

    return result;
  }

  // Future<Map<String,String>> _uploadImage(Uint8List? imageConvertedData, String mediaKey) async {
  //   File tempFile = File('${(await getTemporaryDirectory()).path}/temp.webp');
  //   tempFile.writeAsBytesSync(imageConvertedData!);
  //
  //   // Upload compressed image to Firebase Storage
  //   String fileName = '$mediaKey.webp';
  //   Reference storageRef =
  //       _storage.ref().child('chat_images/$currentUserId/$fileName');
  //
  //   String imageUrl = '';
  //
  //   await storageRef.putFile(tempFile).whenComplete(() async {
  //     await storageRef.getDownloadURL().then((url) {
  //       imageUrl = url;
  //     });
  //   });
  //
  //   await Future.delayed(const Duration(milliseconds: 800));
  //   return {imageUrl: mediaKey};
  // }

  Future<String> _uploadImageAndGetUrl(Uint8List compressedImage, String mediaKey) async {
    File tempFile = File('${(await getTemporaryDirectory()).path}/$mediaKey.webp');
    tempFile.writeAsBytesSync(compressedImage);

    // Upload image to Firebase Storage
    Reference storageRef = _storage.ref().child('chat_images/$currentUserId/$mediaKey.webp');
    await storageRef.putFile(tempFile);

    // Get the URL after the upload completes
    String imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  Future<void> sendImageMessage(bool isUser1, String receiverId, List<Map<String, dynamic>> imageDatas, String message) async {
    final Timestamp timestamp = Timestamp.now();
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    Map<String, ImageData> mediaMap = {};
    List<String> mediaKeys = [];

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Create new message object with placeholder data for images
    ChatMessageModel newMessage = ChatMessageModel(
      isFromUser1: isUser1,
      message: message,
      timestamp: timestamp,
      media: mediaMap,
    );

    // Create the message entry in Firestore first, without image URLs
    DocumentReference docRef = await _firestoreDB
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());

    imageDatas.sort((a, b) => a['index'].compareTo(b['index']));

    // Process each image separately
    for (Map<String, dynamic> image in imageDatas) {
      final String imagePath = image['path'];
      final String mediaKey =  image['index'].toString();
      mediaKeys.add(mediaKey);

      // Compress the image before uploading
      final Uint8List? compressedImage = await _compressImage(imagePath);
      img.Image? imageElement = img.decodeImage(compressedImage!);
      final String dominantColor = await ImageProcessingHelper.getDominantColorFromImage(compressedImage);
      final double ratio = ImageProcessingHelper.calculateAspectRatio(imageElement);
      final List<int> widthAndHeight = ImageProcessingHelper.calculateWidthAndHeight(imageElement);

      // Create an empty ImageData and push to Firestore as a placeholder
      mediaMap[mediaKey] = ImageData(
        imageUrl: '',
        type: 'image',
        isNSFW: image['isNSFW'],
        isLandscape: ratio > 1,
        width: widthAndHeight[0].toDouble(),
        height: widthAndHeight[1].toDouble(),
        dominantColor: dominantColor,
      );

      // Push the empty image data entry to Firestore for each image immediately
      await docRef.update({
        'media.$mediaKey': mediaMap[mediaKey]!.toMap(),
      });

      // Now upload the image to Firebase Storage and update the URL in Firestore
      final String imageUrl = await _uploadImageAndGetUrl(compressedImage, mediaKey);

      // After upload is complete, update Firestore with the image URL
      await docRef.update({
        'media.$mediaKey.imageUrl': imageUrl,
      });

      if (kDebugMode) {
        print('Image uploaded and URL updated for $mediaKey: $imageUrl');
      }
    }

    // Log time for completing the message sending process
    if (kDebugMode) {
      print('Message processing completed in: ${stopwatch.elapsedMilliseconds}ms');
    }
  }


  // Future<void> sendImageMessage(bool isUser1, String receiverId, List<String> imagePaths, String message) async {
  //   final Timestamp timestamp = Timestamp.now();
  //   Stopwatch stopwatch = Stopwatch();
  //   stopwatch.start();
  //
  //   Map<String, ImageData> mediaMap = {};
  //   List<Future<Map<String,String>>> uploadFutures = [];
  //   List<String> mediaKeys = [];
  //
  //   for (int index = 0; index < imagePaths.length; index++) {
  //     String imagePath = imagePaths[index];
  //     final String mediaKey = '${DateTime.now().millisecondsSinceEpoch}_$index';
  //     mediaKeys.add(mediaKey);
  //
  //     final Uint8List? compressedImage = await _compressImage(imagePath);
  //     img.Image? imageElement = img.decodeImage(compressedImage!);
  //     final String dominantColor =
  //         await ImageProcessingHelper.getDominantColorFromImage(
  //             compressedImage);
  //     final double ratio =
  //         ImageProcessingHelper.calculateAspectRatio(imageElement);
  //     final List<int> widthAndHeight =
  //         ImageProcessingHelper.calculateWidthAndHeight(imageElement);
  //
  //     // Add a placeholder entry to the media map
  //     mediaMap[mediaKey] = ImageData(
  //       imageUrl: '',
  //       // Placeholder for now
  //       type: 'image',
  //       isNSFW: false,
  //       isLandscape: ratio > 1,
  //       width: widthAndHeight[0].toDouble(),
  //       height: widthAndHeight[1].toDouble(),
  //       dominantColor: dominantColor,
  //     );
  //
  //     // Start the upload asynchronously
  //     uploadFutures.add(_uploadImage(compressedImage, mediaKey));
  //   }
  //
  //   List<String> ids = [currentUserId, receiverId];
  //   ids.sort();
  //   String chatRoomId = ids.join("_");
  //
  //   ChatMessageModel newMessage = ChatMessageModel(
  //       isFromUser1: isUser1,
  //       message: message,
  //       timestamp: timestamp,
  //       media: mediaMap);
  //
  //   DocumentReference docRef = await _firestoreDB
  //       .collection("ChatRoom")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .add(newMessage.toMap());
  //
  //   if (kDebugMode) {
  //     print(
  //         'Data fetching time for storing: ${stopwatch.elapsedMilliseconds}ms');
  //   }
  //
  //   Future.wait(uploadFutures).then((List<Map<String,String>> imageUrlMap) async {
  //     Map<String, dynamic> updates = {};
  //
  //     for (int i = 0; i < imageUrlMap.length; i++) {
  //       final String mediaKey = imageUrlMap[i].entries.first.value;
  //       final String imageUrl = imageUrlMap[i].entries.first.key;
  //
  //       // Debugging logs
  //       if (kDebugMode) {
  //         print('Updating mediaKey: $mediaKey with imageUrl: $imageUrl');
  //       }
  //
  //       // Add the update for the specific mediaKey
  //       updates['media.$mediaKey.imageUrl'] = imageUrl;
  //     }
  //     // Perform a single update operation
  //     await docRef.update(updates);
  //   }).catchError((error) {
  //     if (kDebugMode) {
  //       print('Error uploading images: $error');
  //     }
  //   });
  //
  //   if (kDebugMode) {
  //     print(
  //         'Data fetching time for updating images: ${stopwatch.elapsedMilliseconds}ms');
  //   }
  //
  //   stopwatch.stop();
  // }


  Map<String, dynamic> getMessageLayoutData(
      Map<String, dynamic> data, Map<String, dynamic>? nextData, bool isUser1) {
    // Align sender message to the right, receiver message to the left
    bool isSender = data['isFromUser1'] == isUser1;
    // Determine whether to show avatar
    bool showAvatar =
        nextData == null || nextData['isFromUser1'] != data['isFromUser1'];

    // Determine whether to show timestamp
    bool showTimestamp =
        nextData == null || nextData['isFromUser1'] != data['isFromUser1'];

    // Spacing based on whether next message is from the same sender
    double spacing =
        (nextData == null || nextData['isFromUser1'] != data['isFromUser1'])
            ? 16.0 // Larger spacing for different senders
            : 4.0; // Smaller spacing for the same sender

    return {
      'isSender': isSender,
      'showAvatar': showAvatar,
      'showTimestamp': showTimestamp,
      'spacing': spacing,
    };
  }
}
