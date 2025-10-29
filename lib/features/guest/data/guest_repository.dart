import '../../../core/services/api_service.dart';

class GuestRepository {
  Future<Map<String, dynamic>> login({required String deviceId}) {
    return ApiService.guestLogin(deviceId: deviceId);
  }
}


