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

  String? validateSignInPassword(String value) {
    if (validateEmpty(value)) {
      return "Please enter a your password";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter (a-z)';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit (0-9)';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }
    return null; // Password is valid
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
