class AccountStatusResponse {
  final bool success;
  final String message;

  AccountStatusResponse({
    required this.success,
    required this.message,
  });

  factory AccountStatusResponse.fromJson(Map<String, dynamic> json) {
    print('[AccountStatusResponse] Parsing JSON: $json');
    
    return AccountStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AccountStatusResponse(success: $success, message: $message)';
  }
}
