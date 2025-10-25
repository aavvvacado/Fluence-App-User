class ProfileCompletionResponse {
  final bool success;
  final String message;
  final ProfileUser user;

  ProfileCompletionResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory ProfileCompletionResponse.fromJson(Map<String, dynamic> json) {
    print('[ProfileCompletionResponse] Parsing JSON: $json');
    
    return ProfileCompletionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: ProfileUser.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProfileCompletionResponse(success: $success, message: $message, user: $user)';
  }
}

class ProfileUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    print('[ProfileUser] Parsing user JSON: $json');
    
    return ProfileUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  @override
  String toString() {
    return 'ProfileUser(id: $id, name: $name, email: $email, phone: $phone)';
  }
}
