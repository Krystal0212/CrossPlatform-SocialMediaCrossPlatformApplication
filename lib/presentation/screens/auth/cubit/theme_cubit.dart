import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

//Sử dụng HydratedCubit để lưu trữ và khôi phục trạng thái
// theme khi ứng dụng khởi động lại.
class ThemeCubit extends HydratedCubit<ThemeMode> {

  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) => emit(themeMode);


  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    return ThemeMode.values[json['theme'] as int];
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme': state.index};
  }


}