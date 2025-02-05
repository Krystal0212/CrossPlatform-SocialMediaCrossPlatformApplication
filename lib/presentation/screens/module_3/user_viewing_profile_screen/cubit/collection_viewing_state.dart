import 'package:socialapp/utils/import.dart';

abstract class CollectionViewingPostState {}

class CollectionViewingPostInitial extends CollectionViewingPostState {}

class CollectionViewingPostLoading extends CollectionViewingPostState {}

class CollectionViewingPostLoaded extends CollectionViewingPostState {
  final List<CollectionModel> collections;

  CollectionViewingPostLoaded(this.collections,);
}

class CollectionViewingPostError extends CollectionViewingPostState {}
