import '../../../../domain/entities/user.dart';

abstract class EditPageState {}

class EditPageInitial extends EditPageState {}

class EditPageLoading extends EditPageState {}
class EditPageLoaded extends EditPageState {
  final UserModel user;
  EditPageLoaded(this.user);
}

class EditPageError extends EditPageState {
  final String message;
  EditPageError(this.message);
}
