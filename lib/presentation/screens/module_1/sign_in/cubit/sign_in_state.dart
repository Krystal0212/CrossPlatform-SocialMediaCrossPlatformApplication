abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInSuccessButNotVerified extends SignInState {}

class SignInSuccessButNotPickTopics extends SignInState {}

class SignInSuccessProcessCompleted extends SignInState {}

class SignInFailure extends SignInState {}