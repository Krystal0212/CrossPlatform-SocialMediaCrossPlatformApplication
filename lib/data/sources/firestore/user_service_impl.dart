import 'package:socialapp/utils/import.dart';

abstract class UserService {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  // No need add to repository
  Future<UserModel?> fetchUserData(String userID);

  Future<void> addCurrentUserData(UserModel addUser);

  Future<void> updateCurrentUserData(UserModel updateUser);

  Future<List<String>> getUserRelatedData(String uid, String dataType);

  Future<String>? uploadAvatar(File image, String uid);
}

class UserServiceImpl extends UserService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  // ToDo : Reference Define
  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference _usersFollowersRef(String uid) {
    return _usersRef.doc(uid).collection('followers');
  }

  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }

  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  // ToDo: Service Functions
  @override
  Future<UserModel?> getUserData(String userID) async {
    try {
      return await fetchUserData(userID);
    } on CustomFirestoreException catch (error) {
      if (kDebugMode) {
        print("${AppStrings.firestoreUserError}: ${error.toString()}");
      }
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      return await fetchUserData(currentUser!.uid);
    } on CustomFirestoreException catch (error) {
      if (error.code == 'new-user') {
        rethrow;
      }
      if (kDebugMode) {
        print("${AppStrings.firestoreUserError}: ${error.toString()}");
      }
      return null;
    }
  }

  // No need add to repository
  @override
  Future<UserModel?> fetchUserData(String userID) async {
    try {
      DocumentSnapshot userDoc = await _usersRef.doc(userID).get();

      if (!userDoc.exists) {
        throw CustomFirestoreException(
          code: 'new-user',
          message: 'User data does not exist in Firestore',
        );
      }

      Map<String, dynamic> documentMap = userDoc.data() as Map<String, dynamic>;
      documentMap['id'] = userDoc.id;

      return UserModel.fromMap(documentMap);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<void> addCurrentUserData(UserModel addUser) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    Map<String, dynamic> userData = addUser.toMap();
    await _usersRef
        .doc(currentUser?.uid)
        .set(userData)
        .then((value) => print("User Added"))
        .catchError((error) => print("Error pushing user data: $error"));
  }

  @override
  Future<String>? uploadAvatar(File image, String uid) async {
    try {
      final storageReference = _storage.ref().child('/user_avatars/$uid');

      UploadTask uploadTask = storageReference.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Uploaded Image URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCurrentUserData(UserModel updateUser) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    try {
      await _usersRef.doc(currentUser?.uid).update(updateUser.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
    }
  }

  @override
  Future<List<String>> getUserRelatedData(String uid, String dataType) async {
    List<String> data = [];
    QuerySnapshot<Map<String, dynamic>> snapshot;

    switch (dataType) {
      case 'followers':
        snapshot = await _usersFollowersRef(uid).get()
            as QuerySnapshot<Map<String, dynamic>>;
        break;
      case 'followings':
        snapshot = await _usersFollowingsRef(uid).get()
            as QuerySnapshot<Map<String, dynamic>>;
        break;
      case 'collections':
        snapshot = await _usersCollectionsRef(uid).get()
            as QuerySnapshot<Map<String, dynamic>>;
        break;
      default:
        throw ArgumentError('Invalid data type: $dataType');
    }

    for (var doc in snapshot.docs) {
      data.add(doc.id);
    }

    if (kDebugMode) {
      print(data.toString());
    }

    return data;
  }
}
