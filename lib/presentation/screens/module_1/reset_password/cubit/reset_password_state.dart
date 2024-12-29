abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;

  ResetPasswordFailure({required this.errorMessage});
}

class VerifyRequestLoading extends ResetPasswordState {}

class VerifyRequestSuccess extends ResetPasswordState {}

class VerifyRequestFailure extends ResetPasswordState {
  final String errorMessage;

  VerifyRequestFailure({required this.errorMessage});
}
