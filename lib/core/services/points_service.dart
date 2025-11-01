import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/points_stats.dart';
import '../models/points_transaction.dart';
import '../utils/shared_preferences_service.dart';

class PointsService {
  // Prefer CASHBACK_SERVICE_URL for points-related APIs; fallback to 4002
  static String get _baseUrl =>
      dotenv.env['WALLET_SERVICE_URL'] ??
      dotenv.env['WALLET_SERVICE_URL'] ??
      'http://10.0.2.2:4005';

  static Future<PointsTransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? source,
    String? status,
  }) async {
    final token = SharedPreferencesService.getAuthToken();
    if (token == null || token.isEmpty) {
      return const PointsTransactionsResponse(
        transactions: [],
        pagination: PointsPagination(page: 1, limit: 20, total: 0, pages: 0),
      );
    }

    final uri = Uri.parse('$_baseUrl/api/points/transactions').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (source != null && source.isNotEmpty) 'source': source,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    // Debug: log request details
    // ignore: avoid_print
    print('[PointsService] GET $uri');

    final res = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    // Debug: log response status
    // ignore: avoid_print
    print('[PointsService] Status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return PointsTransactionsResponse.fromJson(json);
      }
      throw Exception(json['message'] ?? 'Failed to load points transactions');
    }

    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Get points statistics
  static Future<PointsStats> getStats() async {
    final token = SharedPreferencesService.getAuthToken();
    if (token == null || token.isEmpty) {
      // Return default stats for guests or unauthenticated users
      return const PointsStats(
        totalEarned: 0,
        totalRedeemed: 0,
        currentBalance: 0,
        bySource: {},
      );
    }

    final uri = Uri.parse('$_baseUrl/api/points/stats');

    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return PointsStats.fromJson(json);
      }
      throw Exception(json['message'] ?? 'Failed to load points stats');
    }

    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
