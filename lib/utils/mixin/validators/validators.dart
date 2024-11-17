import 'package:email_validator/email_validator.dart';

mixin Validator {
  String? validateName(String? value, String textFieldTitle) {
    if (value == null || value.isEmpty) {
      return 'Please enter a your $textFieldTitle';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a your username';
    } else if (value.length > 20) {
      return 'Your username is too long';
    } else if (value.contains(" ")) {
      return 'You username must not contain spaces';
    }
    return null;
  }

  String? validateEmail(String value) {
    value = value.trim();
    if (validateEmpty(value)) {
      return "Please enter a your email";
    } else if (!EmailValidator.validate(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePassword(String value) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigits = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialCharacters =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (validateEmpty(value)) {
      return "Please enter a your password";
    } else if (value.length < 6) {
      return "Password must have more than 6 symbols";
    } else if (!hasUppercase) {
      return "Password has at least one capital letter";
    } else if (!hasDigits) {
      return "Password has at least one digit";
    } else if (!hasSpecialCharacters) {
      return "Password must have at least one special character";
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (validateEmpty(confirmPassword)) {
      return "Please confirm your password";
    } else if (confirmPassword != password) {
      return "Passwords do not match";
    }
    return null;
  }

  bool validateEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return true;
    }
    return false;
  }
}
