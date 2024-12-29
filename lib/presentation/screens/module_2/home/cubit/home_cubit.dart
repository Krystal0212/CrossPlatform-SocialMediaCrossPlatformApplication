import 'package:socialapp/utils/import.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void reset(){
    emit(HomeInitial());
  }


}
