import 'package:socialapp/utils/import.dart';

abstract class CollectionPickerState {}

class CollectionPickerPostInitial extends CollectionPickerState {}

class CollectionPickerPostLoading extends CollectionPickerState {}

class CollectionPickerPostLoaded extends CollectionPickerState {
  final List<CollectionModel> collections;

  CollectionPickerPostLoaded(this.collections,);
}

class CollectionPickerPostError extends CollectionPickerState {}