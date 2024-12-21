abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationSuccess extends VerificationState {}

class VerificationFailure extends VerificationState {
  final String errorMessage;

  VerificationFailure({required this.errorMessage});
}