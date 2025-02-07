import 'package:socialapp/domain/entities/user.dart';

abstract class ProfileBoxState {}

class ProfileBoxInitial extends ProfileBoxState {}

class ProfileBoxLoading extends ProfileBoxState {}
class ProfileBoxLoaded extends ProfileBoxState {
  final UserModel user;
  ProfileBoxLoaded(this.user);
}

class ProfileBoxError extends ProfileBoxState {
  final String message;
  ProfileBoxError(this.message);
}
