export 'splash/splash.dart';
export 'boarding/boarding.dart';
export 'sign_in/sign_in_screen.dart';
export 'sign_up/sign_up_screen.dart';
export 'verification/verification_screen.dart';
export 'verification/cubit/verification_cubit.dart';
export 'forgot_password/forgot_password_screen.dart';
export 'preferred-topics/preferred_topics_screen.dart';

// OTP not have count down mechanism yet + no have receive the code,
// check if the otp is expired to choose state for verify screen after go from sign in
// add all pop scope cases for module 1
// reset password is not deployed

// boarding (first time installed by mobile) -> sign in -> sign up -> verify OTP (success) -> pick topics -> home
// sign in (new user & verified) -> pick topics -> home
// sign in -> forgot password (type email) -> reset password(verify OTP with link) -> (success) -> sign in
