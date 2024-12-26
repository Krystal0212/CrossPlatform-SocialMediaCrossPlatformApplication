abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationSuccess extends VerificationState {}

class VerificationFailure extends VerificationState {
  final String errorMessage;

  VerificationFailure({required this.errorMessage});
}

class VerificationLoadingFromSignIn extends VerificationState {}

class VerificationNoUserSignedIn extends VerificationState {}

class VerificationSentEmail extends VerificationState{}
