import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/notification.dart';
import '../utils/shared_preferences_service.dart';

class NotificationService {
  static const String _baseUrlKey = 'NOTIFICATION_SERVICE_URL';

  static String get _baseUrl {
    final url = dotenv.env[_baseUrlKey] ?? 'http://localhost:4004';
    print('[NotificationService] Using base URL: $url');
    return url;
  }

  /// Get user notifications with pagination and filtering
  static Future<NotificationResponse> getNotifications({
    int page = 1,
    int limit = 10,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('[NotificationService] Fetching notifications...');
      print('[NotificationService] Base URL: $_baseUrl');
      print('[NotificationService] Page: $page, Limit: $limit');
      print('[NotificationService] Type: $type');
      print('[NotificationService] Start Date: $startDate, End Date: $endDate');

      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$_baseUrl/api/notifications').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (type != null) 'type': type,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      print('[NotificationService] Request URL: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[NotificationService] Response Status: ${response.statusCode}');
      print('[NotificationService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseData['success'] == true && responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            final notificationResponse = NotificationResponse.fromJson(data);
            print(
              '[NotificationService] Success! Fetched ${notificationResponse.notifications.length} notifications',
            );
            return notificationResponse;
          } else {
            // Handle case where there are no notifications
            if (responseData['data'] == null || responseData['data']['notifications'] == null) {
              print('[NotificationService] No notifications found - returning empty list');
              return NotificationResponse(
                notifications: [],
                pagination: Pagination(page: 1, limit: 10, total: 0, pages: 0),
              );
            }
            throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}',
            );
          }
        } catch (e) {
          print('[NotificationService] JSON parsing error: $e');
          throw Exception('Failed to parse notification data: $e');
        }
      } else if (response.statusCode == 404) {
        print(
          '[NotificationService] 404 Error - Route not found. Notification service not available.',
        );
        throw Exception('Notification service not available. Please check if the service is running on port 4004.');
      } else {
        print('[NotificationService] Error: HTTP ${response.statusCode}');
        print('[NotificationService] Error Body: ${response.body}');
        throw Exception(
          'Failed to fetch notifications: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[NotificationService] Timeout during getNotifications: $e');
      rethrow;
    } catch (e) {
      print('[NotificationService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      print('[NotificationService] Fetching unread count...');
      print('[NotificationService] Base URL: $_baseUrl');

      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/notifications/unread-count');

      print('[NotificationService] Request URL: $url');

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

      print('[NotificationService] Response Status: ${response.statusCode}');
      print('[NotificationService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseData['success'] == true && responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            final unreadCount = UnreadCountResponse.fromJson(data);
            print(
              '[NotificationService] Success! Unread count: ${unreadCount.unreadCount}',
            );
            return unreadCount.unreadCount;
          } else {
            // Handle case where there's no unread count data
            print('[NotificationService] No unread count data - returning 0');
            return 0;
          }
        } catch (e) {
          print('[NotificationService] JSON parsing error for unread count: $e');
          return 0; // Return 0 instead of throwing error for unread count
        }
      } else if (response.statusCode == 404) {
        print(
          '[NotificationService] 404 Error - Route not found for unread count.',
        );
        throw Exception('Notification service not available. Please check if the service is running on port 4004.');
      } else {
        print('[NotificationService] Error: HTTP ${response.statusCode}');
        print('[NotificationService] Error Body: ${response.body}');
        throw Exception(
          'Failed to fetch unread count: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[NotificationService] Timeout during getUnreadCount: $e');
      rethrow;
    } catch (e) {
      print('[NotificationService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      print(
        '[NotificationService] Marking notification as read: $notificationId',
      );

      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/notifications/$notificationId/read');

      print('[NotificationService] Request URL: $url');

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[NotificationService] Response Status: ${response.statusCode}');
      print('[NotificationService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('[NotificationService] Success! Notification marked as read');
      } else if (response.statusCode == 404) {
        print(
          '[NotificationService] 404 Error - Route not found for mark as read.',
        );
        throw Exception('Notification service not available. Please check if the service is running on port 4004.');
      } else {
        print('[NotificationService] Error: HTTP ${response.statusCode}');
        print('[NotificationService] Error Body: ${response.body}');
        throw Exception(
          'Failed to mark notification as read: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[NotificationService] Timeout during markAsRead: $e');
      rethrow;
    } catch (e) {
      print('[NotificationService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      print('[NotificationService] Marking all notifications as read...');

      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/notifications/read-all');

      print('[NotificationService] Request URL: $url');

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[NotificationService] Response Status: ${response.statusCode}');
      print('[NotificationService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print(
          '[NotificationService] Success! All notifications marked as read',
        );
      } else if (response.statusCode == 404) {
        print(
          '[NotificationService] 404 Error - Route not found for mark all as read.',
        );
        throw Exception('Notification service not available. Please check if the service is running on port 4004.');
      } else {
        print('[NotificationService] Error: HTTP ${response.statusCode}');
        print('[NotificationService] Error Body: ${response.body}');
        throw Exception(
          'Failed to mark all notifications as read: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[NotificationService] Timeout during markAllAsRead: $e');
      rethrow;
    } catch (e) {
      print('[NotificationService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      print(
        '[NotificationService] Deleting notification: $notificationId',
      );

      final token = SharedPreferencesService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/api/notifications/$notificationId');

      print('[NotificationService] Request URL: $url');

      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('[NotificationService] Response Status: ${response.statusCode}');
      print('[NotificationService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('[NotificationService] Success! Notification deleted');
      } else if (response.statusCode == 404) {
        print(
          '[NotificationService] 404 Error - Route not found for delete.',
        );
        throw Exception('Notification service not available. Please check if the service is running on port 4004.');
      } else {
        print('[NotificationService] Error: HTTP ${response.statusCode}');
        print('[NotificationService] Error Body: ${response.body}');
        throw Exception(
          'Failed to delete notification: HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('[NotificationService] Timeout during deleteNotification: $e');
      rethrow;
    } catch (e) {
      print('[NotificationService] Exception occurred: $e');
      rethrow;
    }
  }

  /// Test notification service connectivity
  static Future<bool> testConnection() async {
    try {
      print('[NotificationService] Testing notification service connection...');
      final url = Uri.parse('$_baseUrl/health');
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      print(
        '[NotificationService] Health check response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } on TimeoutException catch (e) {
      print('[NotificationService] Health check timeout: $e');
      return false;
    } catch (e) {
      print('[NotificationService] Connection test failed: $e');
      return false;
    }
  }

}
