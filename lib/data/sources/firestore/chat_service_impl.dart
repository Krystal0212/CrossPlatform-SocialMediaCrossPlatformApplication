import 'package:socialapp/domain/entities/message.dart';
import 'package:socialapp/utils/import.dart';

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
  Future<void> sendMessage(bool isUser1, String receiverId, String message) async {
    final Timestamp timestamp = Timestamp.now();

    try {
      if (currentUserId.isNotEmpty && currentUserEmail.isNotEmpty){

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
      }
      else {
        throw CustomFirestoreException(code: "no-user-data", message: 'The current user is not found');
      }
    }on CustomFirestoreException catch (error) {
      if (kDebugMode) {
        print('${error.code} : ${error.message}');
      }
    }
  }

  // Get message for chat room
  Stream<QuerySnapshot> getMessages(String receiverId) {
    final String currentUserId = currentUser?.uid ?? '';
    try{
      String chatRoomId = _getChatRoomId(currentUserId, receiverId);

      return _firestoreDB
          .collection("ChatRoom")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .snapshots();
    }catch(error){
      if (kDebugMode) {
        print('Error while retrieving message : $error');
      }
      return const Stream.empty();
    }
  }

  Future<void> sendImageMessage(
      bool isUser1, String receiverId, String imagePath, String message) async {
    final Timestamp timestamp = Timestamp.now();

    // Upload image to Firebase Storage
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef =
        _storage.ref().child('chat_images/$currentUserId/$fileName');

    UploadTask uploadTask = storageRef.putFile(File(imagePath));
    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    ChatMessageModel newMessage = ChatMessageModel(
      isFromUser1: isUser1,
      message: message,
      imageUrl: imageUrl,
      timestamp: timestamp,
    );

    await _firestoreDB
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Map<String, dynamic> getMessageLayoutData(
      Map<String, dynamic> data, Map<String, dynamic>? nextData, bool isUser1) {
    // Align sender message to the right, receiver message to the left
    bool isSender = data['isFromUser1'] == isUser1;
    // Determine whether to show avatar
    bool showAvatar = nextData == null || nextData['isFromUser1'] != data['isFromUser1'];

    // Determine whether to show timestamp
    bool showTimestamp = nextData == null || nextData['isFromUser1'] != data['isFromUser1'];

    // Spacing based on whether next message is from the same sender
    double spacing = (nextData == null || nextData['isFromUser1'] != data['isFromUser1'])
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
