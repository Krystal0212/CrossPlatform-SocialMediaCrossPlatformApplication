import 'package:socialapp/utils/import.dart';
import 'preferred_topic_state.dart';


// if nhap dai url khi ko signed in
// if nhap dai url nhung acc da xong pick cac topic tu lau
class PreferredTopicCubit extends Cubit<PreferredTopicState> {
  PreferredTopicCubit() : super(GetTopicInitial());

  Future<List<Map<TopicModel, bool>>>  fetchTopicsData() async {
    List<Map<TopicModel, bool>> topicsWithBoolean = [];
    try {
      emit(GetTopicLoading());
      topicsWithBoolean = await serviceLocator<TopicRepository>().fetchPreferredTopicsData();
      emit(GetTopicSuccess());
    } catch (e) {
      if (kDebugMode) {
        print("Error");
      }
    }
    return topicsWithBoolean;
  }

  void addCurrentUserData(BuildContext context, List<Map<TopicModel, bool>> categories) async {
    User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();
    try {
      emit(AddUserLoading());
      // UserModel userModel = UserModel.newUser(categories, currentUser!.photoURL, currentUser.email);
      // serviceLocator<UserRepository>().addCurrentUserData(userModel);
      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure());
      if (kDebugMode) {
        print("Error add user: $e");
      }
    }
  }
}
