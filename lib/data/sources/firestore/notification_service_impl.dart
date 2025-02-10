import 'package:socialapp/utils/import.dart';

abstract class NotificationService {
  Stream<List<NotificationModel>> getNotificationStreamOfCurrentUser();

  Future<UserModel> getUserDataFromRef(DocumentReference otherUserRef);

  Future<void> syncReadStatusToFirestore(Map<String, bool> notificationIds);

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications();

  Future<void> deleteReadNotifications();
}

class NotificationServiceImpl extends NotificationService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int loadSize = 5;
  bool noMoreNotification = false;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  String get currentUserId => currentUser?.uid ?? '';

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  CollectionReference _commentPostsRef(String postId) {
    return _postRef.doc(postId).collection('comments');
  }

  // ToDo: Service Functions
  @override
  Stream<List<NotificationModel>> getNotificationStreamOfCurrentUser() {
    DocumentReference currentUserRef = _usersRef.doc(currentUserId);

    return _notificationRef
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data();
        return data['fromUserRef'] != currentUserRef;
      }).map((doc) {
        Map<String, dynamic> data = doc.data();

        data['id'] = doc.id;
        return NotificationModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  @override
  Future<UserModel> getUserDataFromRef(DocumentReference otherUserRef) async {
    DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
    Map<String, dynamic> otherUserData =
        otherUserSnapshot.data() as Map<String, dynamic>;

    otherUserData['id'] = otherUserSnapshot.id;
    otherUserData['preferred-topics'] = {};

    return UserModel.fromMap(otherUserData);
  }

  @override
  Future<void> syncReadStatusToFirestore(
      Map<String, bool> notificationIds) async {
    try {
      if(notificationIds.isEmpty) return;

      WriteBatch batch = _firestoreDB.batch();

      notificationIds.forEach((notificationId, isRead) {
        DocumentReference notificationRef = _notificationRef
            .doc(currentUserId)
            .collection('notifications')
            .doc(notificationId);
        batch.update(notificationRef, {'isRead': isRead});
      });

      await batch.commit();
      notificationIds.clear();
    } catch (error) {
      if (kDebugMode) {
        print('Error syncing read status to Firestore: $error');
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRef
          .doc(currentUserId)
          .collection('notifications')
          .doc(notificationId).delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting notification: $error');
      }
    }
  }

  @override
  Future<void> deleteReadNotifications() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      _notificationRef
          .doc(currentUserId)
          .collection('notifications')
          .where('isRead', isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        // Commit batch after collecting all deletions
        batch.commit();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting read notifications: $error');
      }
    }
  }


  @override
  Future<void> deleteAllNotifications() async {
    try {
      final snapshot = await _notificationRef
          .doc(currentUserId)
          .collection('notifications')
          .get();

      final batch = _firestoreDB.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

    }catch(error){
      if (kDebugMode) {
        print('Error deleting all notification: $error');
      }
    }
  }
}
