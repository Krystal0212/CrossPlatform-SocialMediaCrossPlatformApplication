import 'dart:ui';

import 'package:socialapp/domain/entities/notification.dart';
import 'package:socialapp/utils/import.dart';
import 'package:image/image.dart' as img;

import 'notification_service_impl.dart';

abstract class ChatService {
  Future<void> sendMessage(bool isUser1, String receiverId, String message);

  Stream<QuerySnapshot> getMessages(String receiverId);

  Map<String, dynamic> getMessageLayoutData(
      Map<String, dynamic> data, Map<String, dynamic>? nextData, bool isUser1);

  Stream<List<Map<String, dynamic>>>? getCurrentUserContactListSnapshot();

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream(
      String chatRoomId);

  Future<void> sendImageMessage(bool isUser1, String receiverId,
      List<Map<String, dynamic>> imageDatas, String message);

  Future<List<UserModel>> getUserFollowingsList();

  DocumentReference<Object?> getUserRef(String userId);

  Future<List<UserModel>> findingUserList(String userTagNameToFind);

  Future<bool> checkIsUser1(String otherUserId);
}

class ChatServiceImpl extends ChatService with ImageAndVideoProcessingHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  String get currentUserId => currentUser?.uid ?? '';

  String get currentUserEmail => currentUser?.email.toString() ?? '';

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _chatRoomRef => _firestoreDB.collection('ChatRoom');

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }

  // ToDo: Service Functions
  String _getChatRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort(); // Sort ids to ensure chatRoomId is the same for every pair of chatter
    return ids.join("_");
  }

  Future<void> _checkAndCreateChatRoom(
    String chatRoomId,
    String receiverId,
  ) async {
    try {
      DocumentReference user1Ref = _usersRef.doc(currentUserId);
      DocumentReference user2Ref = _usersRef.doc(receiverId);
      DocumentSnapshot docSnapshot = await _chatRoomRef.doc(chatRoomId).get();

      if (!docSnapshot.exists) {
        await _chatRoomRef.doc(chatRoomId).set({
          'user1Ref': user1Ref,
          'user2Ref': user2Ref,
        });

        await user1Ref.update({
          'interacts': FieldValue.arrayUnion([user2Ref]),
        });

        // Add user1Ref to user2's 'interacts' field
        await user2Ref.update({
          'interacts': FieldValue.arrayUnion([user1Ref]),
        });

        DocumentSnapshot followingRef =
            await _usersFollowingsRef(currentUserId).doc(receiverId).get();

        bool isFollowing = followingRef.exists;

        if (!isFollowing) {
          await _chatRoomRef.doc(chatRoomId).set({
            'user1Ref': user1Ref,
            'user2Ref': user2Ref,
            'strangers': [user1Ref],
            'isUser1Deleted': false,
            'isUser2Deleted': false,
          });
        } else {
          await _chatRoomRef.doc(chatRoomId).set({
            'user1Ref': user1Ref,
            'user2Ref': user2Ref,
            'isUser1Deleted': false,
            'isUser2Deleted': false,
          });
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during chat room creation : $error');
      }
    }
  }

  Future<void> _sendMessageNotification(
      String chatRoomId, String receiverId, NotificationType type) async {
    try {
      CollectionReference notificationsRef =
          _notificationRef.doc(receiverId).collection('notifications');

      // Check if the document exists
      DocumentReference userNotificationsRef = _notificationRef.doc(receiverId);
      DocumentSnapshot userDocSnapshot = await userNotificationsRef.get();

      // If document doesn't exist, create it
      if (!userDocSnapshot.exists) {
        await userNotificationsRef.set({'list': []});
      }

      Timestamp fifteenMinutesAgo = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch - (15 * 60 * 1000));

      QuerySnapshot querySnapshot = await notificationsRef
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('timestamp',
              isGreaterThan: fifteenMinutesAgo) // Check last 15 min
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      NotificationModel newNotification = NotificationModel.newNotification(
        type: type.name,
        fromUserRef: _usersRef.doc(currentUserId),
        toUserId: receiverId,
        chatRoomId: chatRoomId,
        timestamp: Timestamp.now(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.set(newNotification.toMap());
      } else {
        await notificationsRef.add(newNotification.toMap());
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error sending notification: $error');
      }
    }
  }

  @override
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

        await _checkAndCreateChatRoom(chatRoomId, receiverId);

        // Add new message to database
        await _chatRoomRef
            .doc(chatRoomId)
            .collection("messages")
            .add(newMessage.toMap());

        // Check if receiver is a stranger
        DocumentSnapshot chatRoomSnapshot =
            await _chatRoomRef.doc(chatRoomId).get();
        List<dynamic> strangers = chatRoomSnapshot.get('strangers') ?? [];

        if (strangers.contains(_usersRef.doc(receiverId))) {
          await _chatRoomRef.doc(chatRoomId).update({
            'strangers': FieldValue.arrayRemove([_usersRef.doc(receiverId)])
          });

          await _usersRef.doc(currentUserId).update({
            'interacts': FieldValue.arrayUnion(['']),
          });

          // Remove the empty string from the 'interacts' field to revert the change
          await _usersRef.doc(currentUserId).update({
            'interacts': FieldValue.arrayRemove(['']),
          });
        }

        // Send notification to receiver
        await _sendMessageNotification(
            chatRoomId, receiverId, NotificationType.textMessage);
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

  @override
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

  Future<String> _uploadImageAndGetUrl(
      Uint8List compressedImage, String mediaKey) async {
    File tempFile =
        File('${(await getTemporaryDirectory()).path}/$mediaKey.webp');
    tempFile.writeAsBytesSync(compressedImage);

    // Upload image to Firebase Storage
    Reference storageRef =
        _storage.ref().child('chat_images/$currentUserId/$mediaKey.webp');
    await storageRef.putFile(tempFile);

    // Get the URL after the upload completes
    String imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  @override
  Future<void> sendImageMessage(bool isUser1, String receiverId,
      List<Map<String, dynamic>> imageDatas, String message) async {
    try {
      final Timestamp timestamp = Timestamp.now();

      Map<String, ImageData> mediaMap = {};
      List<String> mediaKeys = [];

      String chatRoomId = _getChatRoomId(currentUserId, receiverId);

      await _checkAndCreateChatRoom(chatRoomId, receiverId);

      // Create new message object with placeholder data for images
      ChatMessageModel newMessage = ChatMessageModel(
        isFromUser1: isUser1,
        message: message,
        timestamp: timestamp,
        media: mediaMap,
      );

      // Create the message entry in Firestore first, without image URLs
      DocumentReference docRef = await _chatRoomRef
          .doc(chatRoomId)
          .collection("messages")
          .add(newMessage.toMap());

      imageDatas.sort((a, b) => a['index'].compareTo(b['index']));

      // Process each image separately
      for (Map<String, dynamic> image in imageDatas) {
        final String imagePath = image['path'];
        final String mediaKey = image['index'].toString();
        mediaKeys.add(mediaKey);

        // Compress the image before uploading
        final Uint8List? compressedImage = await _compressImage(imagePath);
        img.Image? imageElement = img.decodeImage(compressedImage!);
        final String dominantColor =
            await getDominantColorFromImage(compressedImage);
        final double ratio = calculateAspectRatio(imageElement);
        final List<int> widthAndHeight = calculateWidthAndHeight(imageElement);

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
        final String imageUrl =
            await _uploadImageAndGetUrl(compressedImage, mediaKey);

        // After upload is complete, update Firestore with the image URL
        await docRef.update({
          'media.$mediaKey.imageUrl': imageUrl,
        });
      }

      // Check if receiver is a stranger
      DocumentSnapshot chatRoomSnapshot =
          await _chatRoomRef.doc(chatRoomId).get();
      List<dynamic> strangers = chatRoomSnapshot.get('strangers') ?? [];

      if (strangers.contains(_usersRef.doc(receiverId))) {
        await _chatRoomRef.doc(chatRoomId).update({
          'strangers': FieldValue.arrayRemove([_usersRef.doc(receiverId)])
        });

        await _usersRef.doc(currentUserId).update({
          'interacts': FieldValue.arrayUnion(['']),
        });

        // Remove the empty string from the 'interacts' field to revert the change
        await _usersRef.doc(currentUserId).update({
          'interacts': FieldValue.arrayRemove(['']),
        });
      }

      NotificationType notificationType = (imageDatas.length == 1)
          ? NotificationType.singleImageMessage
          : NotificationType.multipleImageMessage;
      await _sendMessageNotification(chatRoomId, receiverId, notificationType);
    } catch (error) {
      if (kDebugMode) {
        print('Error during sending image message : $error');
      }
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

  Future<void> putRemoveMaskForChatRoom(String chatRoomId) async {
    _chatRoomRef.doc(chatRoomId).update({});
  }

  @override
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

  @override
  Stream<List<Map<String, dynamic>>>? getCurrentUserContactListSnapshot() {
    return _usersRef.doc(currentUserId).snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> contactList = []; // Initialize an empty list
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty && data['interacts'] is List) {
          final List interacts = data['interacts'];
          for (final userRef in interacts) {
            String chatRoomId = _getChatRoomId(userRef.id, currentUserId);
            DocumentSnapshot chatRoomSnapshot =
                await _chatRoomRef.doc(chatRoomId).get();

            Map<String, dynamic> chatRoomData =
                chatRoomSnapshot.data() as Map<String, dynamic>;
            final List strangers = chatRoomData['strangers'] ?? [];

            if (!strangers.contains(_usersRef.doc(userRef.id))) {
              chatRoomData['id'] = chatRoomId;
              contactList
                  .add({'chatRoomData': chatRoomData, 'isStranger': false});
            } else {
              chatRoomData['id'] = chatRoomId;
              contactList
                  .add({'chatRoomData': chatRoomData, 'isStranger': true});
            }
          }
        }
      }
      return contactList; // Return the list of maps
    });
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream(
      String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  @override
  Future<bool> checkIsUser1(String otherUserId) async {
    try {
      String chatRoomId = _getChatRoomId(currentUserId, otherUserId);

      DocumentSnapshot snapshot = await _chatRoomRef.doc(chatRoomId).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      DocumentReference user1Ref = data['user1Ref'];

      return user1Ref.id == currentUserId;
    } catch (error) {
      if (kDebugMode) {
        print('Error during checkIsUser1 : $error');
      }
      return false;
    }
  }

  @override
  DocumentReference<Object?> getUserRef(String userId) {
    return _usersRef.doc(userId);
  }

  @override
  Future<List<UserModel>> getUserFollowingsList() async {
    try {
      QuerySnapshot followingsRef =
          await _usersFollowingsRef(currentUserId).get();

      List<String> followingIds = [];
      if (followingsRef.docs.isNotEmpty) {
        followingIds = followingsRef.docs.map((doc) => doc.id).toList();
      }

      List<UserModel> followings = [];

      for (String id in followingIds) {
        DocumentSnapshot<Object?> value = await _usersRef.doc(id).get();
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;

        data['id'] = value.id;
        followings.add(UserModel.fromFollowingMap(data));
      }

      return followings;
    } catch (error) {
      if (kDebugMode) {
        print('Error get following list : $error');
      }

      return [];
    }
  }

  @override
  Future<List<UserModel>> findingUserList(String userTagNameToFind) async {
    try {
      String searchKey = userTagNameToFind.toLowerCase();
      String endKey = '$searchKey\uf8ff';

      QuerySnapshot querySnapshot = await _usersRef
          .where('tag-name', isGreaterThanOrEqualTo: searchKey)
          .where('tag-name', isLessThanOrEqualTo: endKey)
          .get();

      List<UserModel> users = querySnapshot.docs
          .where((doc) => doc.id != currentUserId) // Remove current user
          .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromFollowingMap(data);
      }).toList();

      return users;
    } catch (error) {
      if (kDebugMode) {
        print('Error finding users: $error');
      }
      return [];
    }
  }
}