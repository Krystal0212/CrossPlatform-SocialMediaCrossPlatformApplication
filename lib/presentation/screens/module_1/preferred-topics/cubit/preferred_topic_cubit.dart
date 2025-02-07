import 'package:socialapp/utils/import.dart';
import 'preferred_topic_state.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

// if nhap dai url khi ko signed in
// if nhap dai url nhung acc da xong pick cac topic tu lau
class PreferredTopicCubit extends Cubit<PreferredTopicState> {
  PreferredTopicCubit() : super(GetTopicInitial());

  Future<List<Map<TopicModel, bool>>> fetchTopicsData() async {
    List<Map<TopicModel, bool>> topicsWithBoolean = [];
    try {
      emit(GetTopicLoading());
      topicsWithBoolean =
          await serviceLocator<TopicRepository>().fetchPreferredTopicsData();
      emit(GetTopicSuccess());
    } catch (e) {
      if (kDebugMode) {
        print("Error");
      }
    }
    return topicsWithBoolean;
  }

  Map<String, bool> convertToMapStringBool(
      List<Map<TopicModel, bool>> categories) {
    List<Map<TopicModel, bool>> items =
        categories.where((mapValue) => mapValue.containsValue(true)).toList();
    Map<String, bool> mergedMap = {};
    for (Map<TopicModel, bool> mapValue in items) {
      Map<String, bool> mapTopic = {
        for (MapEntry<TopicModel, bool> entry in mapValue.entries)
          entry.key.topicId: entry.value
      };
      mergedMap.addAll(mapTopic);
    }
    return mergedMap;
  }

  void addCurrentUserData(
      BuildContext context, List<Map<TopicModel, bool>> categories) async {
    User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();

    String email = currentUser?.email ?? "";
    String emailWithoutDomain = email.split('@').first;
    String dateTag = DateFormat('ddMM').format(DateTime.now());

    Uint8List bytes = utf8.encode(emailWithoutDomain);
    Digest digest = sha256.convert(bytes);
    String encryptedPart = digest.toString().substring(0, 4);
    String tagName = 'user$encryptedPart$dateTag';

    Map<String, bool> mergedMap = convertToMapStringBool(categories);

    try {
      emit(AddUserLoading());
      UserModel userModel = UserModel.newUser(
          mergedMap, currentUser!.photoURL, currentUser.email, tagName );
      await serviceLocator<UserRepository>().addCurrentUserData(userModel);
      if (!context.mounted) return;
      context.go('/home');
      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure());
      if (kDebugMode) {
        print("Error add user: $e");
      }
    }
  }
}
