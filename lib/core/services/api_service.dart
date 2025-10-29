import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../utils/shared_preferences_service.dart';

class ApiService {
  static const String _baseUrlKey = 'AUTH_SERVICE_URL';
  static const String _firebaseAuthEndpointKey = 'FIREBASE_AUTH_ENDPOINT';

  static String get _baseUrl =>
      dotenv.env[_baseUrlKey] ?? 'http://localhost:4001';
  static String get _firebaseAuthEndpoint =>
      dotenv.env[_firebaseAuthEndpointKey] ?? '/api/auth/firebase';

  /// Firebase Authentication API call
  /// Sends Firebase ID token to backend for verification and JWT token generation
  static Future<Map<String, dynamic>> authenticateWithFirebase({
    required String idToken,
    String? referralCode,
  }) async {
    try {
      print('[ApiService] Starting Firebase authentication...');
      print('[ApiService] Base URL: $_baseUrl');
      print('[ApiService] Endpoint: $_firebaseAuthEndpoint');
      print('[ApiService] ID Token: ${idToken.substring(0, 20)}...');
      print('[ApiService] Referral Code: $referralCode');

      final url = Uri.parse('$_baseUrl$_firebaseAuthEndpoint');

      final requestBody = {
        'idToken': idToken,
        if (referralCode != null) 'referralCode': referralCode,
      };

      print('[ApiService] Request URL: $url');
      print('[ApiService] Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      print('[ApiService] Response Status: ${response.statusCode}');
      print('[ApiService] Response Headers: ${response.headers}');
      print('[ApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('[ApiService] Success! Parsed response: $responseData');
        return responseData;
      } else {
        print('[ApiService] Error: HTTP ${response.statusCode}');
        print('[ApiService] Error Body: ${response.body}');
        throw Exception('Authentication failed: HTTP ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('[ApiService] Timeout during authenticateWithFirebase: $e');
      rethrow;
    } catch (e) {
      print('[ApiService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Complete user profile after initial registration
  static Future<Map<String, dynamic>> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
    required String email,
    required String authToken,
  }) async {
    try {
      print('[ApiService] Starting profile completion...');
      print('[ApiService] Name: $name');
      print('[ApiService] Phone: $phone');
      print('[ApiService] Date of Birth: $dateOfBirth');
      print('[ApiService] Email: $email');

      final url = Uri.parse('$_baseUrl/api/auth/complete-profile');

      final requestBody = {
        'name': name,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'email': email,
      };

      print('[ApiService] Request URL: $url');
      print('[ApiService] Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      print('[ApiService] Response Status: ${response.statusCode}');
      print('[ApiService] Response Headers: ${response.headers}');
      print('[ApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(
          '[ApiService] Profile completion success! Parsed response: $responseData',
        );
        return responseData;
      } else {
        print('[ApiService] Error: HTTP ${response.statusCode}');
        print('[ApiService] Error Body: ${response.body}');
        throw Exception(
          'Profile completion failed: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[ApiService] Timeout during completeProfile: $e');
      rethrow;
    } catch (e) {
      print('[ApiService] Profile completion exception: $e');
      rethrow;
    }
  }

  /// Update account status
  static Future<Map<String, dynamic>> updateAccountStatus({
    required String status,
    required String authToken,
  }) async {
    try {
      print('[ApiService] Starting account status update...');
      print('[ApiService] Status: $status');

      final url = Uri.parse('$_baseUrl/api/auth/account/status');

      final requestBody = {'status': status};

      print('[ApiService] Request URL: $url');
      print('[ApiService] Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      print('[ApiService] Response Status: ${response.statusCode}');
      print('[ApiService] Response Headers: ${response.headers}');
      print('[ApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(
          '[ApiService] Account status update success! Parsed response: $responseData',
        );
        return responseData;
      } else {
        print('[ApiService] Error: HTTP ${response.statusCode}');
        print('[ApiService] Error Body: ${response.body}');
        throw Exception(
          'Account status update failed: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[ApiService] Timeout during updateAccountStatus: $e');
      rethrow;
    } catch (e) {
      print('[ApiService] Account status update exception: $e');
      rethrow;
    }
  }

  /// Test API connectivity
  static Future<bool> testConnection() async {
    try {
      print('[ApiService] Testing API connection...');
      final url = Uri.parse('$_baseUrl/health');
      final response = await http
          .get(
        url,
        headers: {'Accept': 'application/json'},
      )
          .timeout(const Duration(seconds: 8));

      print('[ApiService] Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } on TimeoutException catch (e) {
      print('[ApiService] Health check timeout: $e');
      return false;
    } catch (e) {
      print('[ApiService] Connection test failed: $e');
      return false;
    }
  }

  /// Fetch list of active merchants from backend
  static Future<List<dynamic>> fetchActiveMerchants() async {
    final base = dotenv.env['MERCHANT_SERVICE_URL'] ?? 'http://10.0.2.2:4003';
    final url = Uri.parse('$base/api/profiles/active');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to fetch merchants: \\${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchCashbackCampaigns() async {
    final base = dotenv.env['CASHBACK_SERVICE_URL'] ?? 'http://10.0.2.2:4002';
    final url = Uri.parse('$base/api/campaigns');
    final token = SharedPreferencesService.getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response =
        await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Return the full data object which contains { campaigns: [...], pagination: {...} }
      return data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch campaigns: \\${response.statusCode}');
    }
  }

  /// Guest login - returns { success, guestId, token }
  static Future<Map<String, dynamic>> guestLogin({
    required String deviceId,
  }) async {
    final base = dotenv.env['AUTH_SERVICE_URL'] ?? 'http://10.0.2.2:4001';
    final url = Uri.parse('$base/api/guest/login');
    print('[ApiService] Guest login URL: $url  deviceId=$deviceId');
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'deviceId': deviceId}),
    )
        .timeout(const Duration(seconds: 10));
    print(
      '[ApiService] Guest login status: ${response.statusCode} body: ${response.body}',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Guest login failed: \\${response.statusCode}');
    }
  }

  static Future<int> fetchTotalPointsEarned() async {
    final base = dotenv.env['CASHBACK_SERVICE_URL'] ?? 'http://10.0.2.2:4002';
    final url = Uri.parse('$base/api/points/stats');
    final token = SharedPreferencesService.getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response =
        await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data']?['totalEarned'] ?? 0) as int;
    } else {
      throw Exception('Failed to fetch points stats: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchWalletBalance() async {
    final base = dotenv.env['CASHBACK_SERVICE_URL'] ?? 'http://10.0.2.2:4002';
    final url = Uri.parse('$base/api/wallet/balance');
    final token = SharedPreferencesService.getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response =
        await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] ?? {}) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch wallet balance: ${response.statusCode}');
    }
  }
}
