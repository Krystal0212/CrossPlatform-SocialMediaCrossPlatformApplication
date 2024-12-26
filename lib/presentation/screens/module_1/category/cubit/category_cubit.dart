import 'package:socialapp/utils/import.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(GetCategoryIDInitial());

  AuthRepository authRepository = AuthRepositoryImpl();
  String? _category;

  void getCategoryId(String? categoryId) async {
    if (categoryId == null) {
      emit(GetCategoryIDFailure());
    } else {
      _category = categoryId;
      emit(GetCategoryIDSuccess());
    }
  }

  void addCurrentUserData(BuildContext context) async {
    User? currentUser = await authRepository.getCurrentUser();
    try {
      emit(AddUserLoading());
      UserModel userModel = UserModel.newUser(
          _category!, currentUser!.photoURL, currentUser.email);
      serviceLocator<UserRepository>().addCurrentUserData(userModel);
      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure());
      if (kDebugMode) {
        print("Error add user: $e");
      }
    }
  }
}
