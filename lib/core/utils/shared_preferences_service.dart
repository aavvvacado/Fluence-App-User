import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _tokenKey = 'auth_token';
  static const String _guestTokenKey = 'guest_token';
  static const String _guestIdKey = 'guest_id';
  static const String _isGuestKey = 'is_guest';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _savedEmailsKey = 'saved_emails';
  static const String _profilePhoneKey = 'profile_phone';
  static const String _needsProfileCompletionKey = 'needs_profile_completion';
  // Temp signup details to prefill profile completion
  static const String _tempSignupEmailKey = 'temp_signup_email';
  static const String _tempSignupPhoneKey = 'temp_signup_phone';
  static const String _tempSignupDobKey = 'temp_signup_dob';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    print('[SharedPreferencesService] Saving token: $token');
    await _prefs?.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(_tokenKey);
  }

  // User data management
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    print('[SharedPreferencesService] Saving userId=$userId, email=$email, name=$name');
    await _prefs?.setString(_userIdKey, userId);
    await _prefs?.setString(_userEmailKey, email);
    await _prefs?.setString(_userNameKey, name);
    await _prefs?.setBool(_isLoggedInKey, true);
  }

  static String? getUserId() {
    return _prefs?.getString(_userIdKey);
  }

  static String? getUserEmail() {
    return _prefs?.getString(_userEmailKey);
  }

  static String? getUserName() {
    return _prefs?.getString(_userNameKey);
  }

  // Get user name for a specific email (for login flow)
  static String? getUserNameForEmail(String email) {
    final savedEmail = _prefs?.getString(_userEmailKey);
    final savedName = _prefs?.getString(_userNameKey);
    print('[SharedPreferencesService] getUserNameForEmail - Input email: $email');
    print('[SharedPreferencesService] getUserNameForEmail - Saved email: $savedEmail');
    print('[SharedPreferencesService] getUserNameForEmail - Saved name: $savedName');
    
    if (savedEmail == email) {
      print('[SharedPreferencesService] Email match found! Returning name: $savedName');
      return savedName;
    }
    print('[SharedPreferencesService] No email match found, returning null');
    return null;
  }

  static bool isLoggedIn() {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  static String? getAuthToken() {
    return _prefs?.getString(_tokenKey);
  }

  // Guest session management
  static Future<void> saveGuestSession({required String guestId, required String token}) async {
    await _prefs?.setString(_guestIdKey, guestId);
    await _prefs?.setString(_guestTokenKey, token);
    await _prefs?.setBool(_isGuestKey, true);
  }

  static String? getGuestToken() => _prefs?.getString(_guestTokenKey);
  static String? getGuestId() => _prefs?.getString(_guestIdKey);
  static bool isGuest() => _prefs?.getBool(_isGuestKey) ?? false;

  static Future<void> clearGuestSession() async {
    await _prefs?.remove(_guestIdKey);
    await _prefs?.remove(_guestTokenKey);
    await _prefs?.remove(_isGuestKey);
  }

  // Email history management
  static Future<void> saveEmail(String email) async {
    final savedEmails = getSavedEmails();
    if (!savedEmails.contains(email)) {
      savedEmails.add(email);
      await _prefs?.setStringList(_savedEmailsKey, savedEmails);
      print('[SharedPreferencesService] Saved email: $email');
    }
  }

  static List<String> getSavedEmails() {
    return _prefs?.getStringList(_savedEmailsKey) ?? [];
  }

  static Future<void> clearSavedEmails() async {
    await _prefs?.remove(_savedEmailsKey);
  }

  static Future<void> saveProfilePhone(String phone) async {
    await _prefs?.setString(_profilePhoneKey, phone);
  }
  static String? getProfilePhone() {
    return _prefs?.getString(_profilePhoneKey);
  }

  static Future<void> setNeedsProfileCompletionFlag(bool value) async {
    await _prefs?.setBool(_needsProfileCompletionKey, value);
  }
  static bool? getNeedsProfileCompletionFlag() {
    return _prefs?.getBool(_needsProfileCompletionKey);
  }

  static Future<void> saveFullUserProfile({required String id, required String name, required String email, required String phone}) async {
    print('[SharedPreferencesService] Saving FULL user: id=$id, name=$name, email=$email, phone=$phone');
    await saveUserData(userId: id, email: email, name: name);
    await saveProfilePhone(phone);
  }

  // Temp signup detail helpers for prefill
  static Future<void> saveTempSignupEmail(String email) async {
    await _prefs?.setString(_tempSignupEmailKey, email);
  }
  static String? getTempSignupEmail() => _prefs?.getString(_tempSignupEmailKey);

  static Future<void> saveTempSignupPhone(String phone) async {
    await _prefs?.setString(_tempSignupPhoneKey, phone);
  }
  static String? getTempSignupPhone() => _prefs?.getString(_tempSignupPhoneKey);

  static Future<void> saveTempSignupDob(String dob) async {
    await _prefs?.setString(_tempSignupDobKey, dob);
  }
  static String? getTempSignupDob() => _prefs?.getString(_tempSignupDobKey);

  static Future<void> clearTempSignupDetails() async {
    await _prefs?.remove(_tempSignupEmailKey);
    await _prefs?.remove(_tempSignupPhoneKey);
    await _prefs?.remove(_tempSignupDobKey);
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    print('[SharedPreferencesService] Clearing auth data');
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_userEmailKey);
    await _prefs?.remove(_userNameKey);
    await _prefs?.setBool(_isLoggedInKey, false);
  }
}
