class PhoneVerificationService {
  static String? _verificationId;
  static String? _phoneNumber;

  static void storeVerificationData(String verificationId, String phoneNumber) {
    _verificationId = verificationId;
    _phoneNumber = phoneNumber;
  }

  static String? get verificationId => _verificationId;
  static String? get phoneNumber => _phoneNumber;

  static void clearVerificationData() {
    _verificationId = null;
    _phoneNumber = null;
  }
}
