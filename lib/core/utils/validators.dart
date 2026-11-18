class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? validateCollegeId(String? value) {
    if (value == null || value.trim().isEmpty) return 'College ID is required';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final price = double.tryParse(value.trim());
    if (price == null) return 'Enter a valid price';
    if (price <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) return 'UPI ID is required';
    final upiRegex = RegExp(r'^[\w.\-_]{2,256}@[a-zA-Z]{2,64}$');
    if (!upiRegex.hasMatch(value.trim())) return 'Enter a valid UPI ID (e.g. name@okicici)';
    return null;
  }

  static String? validateStallName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Stall name is required';
    if (value.trim().length < 2) return 'Stall name must be at least 2 characters';
    return null;
  }

  static String? validateCustomMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter minutes';
    final minutes = int.tryParse(value.trim());
    if (minutes == null) return 'Enter a valid number';
    if (minutes <= 0) return 'Minutes must be greater than 0';
    if (minutes > 120) return 'Maximum 120 minutes';
    return null;
  }
}
