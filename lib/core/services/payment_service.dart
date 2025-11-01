import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/wallet_balance.dart';
import '../utils/shared_preferences_service.dart';

class PaymentService {
  static final String _baseUrl =
      dotenv.env['PAYMENT_SERVICE_URL'] ?? 'http://10.0.2.2:4005';

  /// Process a payment transaction
  static Future<Map<String, dynamic>> processPayment({
    required String merchantCode,
    required double amount,
    required String transactionId,
  }) async {
    try {
      final token = SharedPreferencesService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/payments/process');

      print('[PaymentService] Processing payment...');
      print('[PaymentService] Merchant Code: $merchantCode');
      print('[PaymentService] Amount: $amount');
      print('[PaymentService] Transaction ID: $transactionId');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'merchantCode': merchantCode,
              'amount': amount,
              'transactionId': transactionId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('[PaymentService] Response Status: ${response.statusCode}');
      print('[PaymentService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          print('[PaymentService] Payment processed successfully');
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            'Payment failed: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        print('[PaymentService] Error: HTTP ${response.statusCode}');
        print('[PaymentService] Error Body: ${response.body}');
        throw Exception(
          'Failed to process payment: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[PaymentService] Timeout during payment processing: $e');
      rethrow;
    } catch (e) {
      print('[PaymentService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Get merchant information by code
  static Future<Map<String, dynamic>> getMerchantByCode(String code) async {
    try {
      final token = SharedPreferencesService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/merchants/$code');

      print('[PaymentService] Fetching merchant: $code');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[PaymentService] Response Status: ${response.statusCode}');
      print('[PaymentService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          print('[PaymentService] Merchant found');
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            'Merchant not found: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Merchant with code "$code" not found');
      } else {
        print('[PaymentService] Error: HTTP ${response.statusCode}');
        print('[PaymentService] Error Body: ${response.body}');
        throw Exception(
          'Failed to fetch merchant: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[PaymentService] Timeout during merchant fetch: $e');
      rethrow;
    } catch (e) {
      print('[PaymentService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Get user's wallet balance
  static Future<WalletBalance> getBalance() async {
    try {
      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        // Return default balance for guests or unauthenticated users
        return WalletBalance(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          currency: '',
          lastUpdated: DateTime.now(),
        );
      }

      final url = Uri.parse('$_baseUrl/api/wallet/balance');

      print('[PaymentService] Fetching wallet balance');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[PaymentService] Response Status: ${response.statusCode}');
      print('[PaymentService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          print('[PaymentService] Wallet balance fetched');
          return WalletBalance.fromJson(responseData);
        } else {
          throw Exception(
            'Failed to fetch balance: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        print('[PaymentService] Error: HTTP ${response.statusCode}');
        print('[PaymentService] Error Body: ${response.body}');
        throw Exception(
          'Failed to fetch wallet balance: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[PaymentService] Timeout during balance fetch: $e');
      rethrow;
    } catch (e) {
      print('[PaymentService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Get user's wallet balance (legacy method for backward compatibility)
  static Future<Map<String, dynamic>> getWalletBalance() async {
    final balance = await getBalance();
    return balance.toJson();
  }

  /// Validate payment amount
  static Future<bool> validatePaymentAmount(double amount) async {
    try {
      final balance = await getWalletBalance();
      final availableBalance = (balance['availableBalance'] ?? 0.0).toDouble();

      return amount > 0 && amount <= availableBalance;
    } catch (e) {
      print('[PaymentService] Error validating amount: $e');
      return false;
    }
  }

  /// Generate transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TX$timestamp$random';
  }
}
