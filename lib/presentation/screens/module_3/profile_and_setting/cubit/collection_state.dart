import 'package:socialapp/utils/import.dart';

abstract class CollectionPostState {}

class CollectionPostInitial extends CollectionPostState {}

class CollectionPostLoading extends CollectionPostState {}

class CollectionPostLoaded extends CollectionPostState {
  final Stream<List<CollectionModel>> collections;

  CollectionPostLoaded(this.collections,);
}

class CollectionPostError extends CollectionPostState {}
