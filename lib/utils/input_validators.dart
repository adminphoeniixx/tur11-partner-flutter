class InputValidators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? phone(String? value, {String label = 'Mobile number'}) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) return requiredError;
    return isValidPhone(value!) ? null : '$label must be exactly 10 digits.';
  }

  static String? email(String? value, {String label = 'Email'}) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) return requiredError;
    return isValidEmail(value!) ? null : 'Enter a valid email address.';
  }

  static bool isValidPhone(String value) {
    return RegExp(r'^\d{10}$').hasMatch(value.trim());
  }

  static bool isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }
}
