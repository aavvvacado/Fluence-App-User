class ApiAuthResponse {
  final ApiUser user;
  final String token;
  final bool needsProfileCompletion;

  ApiAuthResponse({
    required this.user,
    required this.token,
    required this.needsProfileCompletion,
  });

  factory ApiAuthResponse.fromJson(Map<String, dynamic> json) {
    print('[ApiAuthResponse] Parsing JSON: $json');
    
    return ApiAuthResponse(
      user: ApiUser.fromJson(json['user']),
      token: json['token'] ?? '',
      needsProfileCompletion: json['needsProfileCompletion'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'needsProfileCompletion': needsProfileCompletion,
    };
  }

  @override
  String toString() {
    return 'ApiAuthResponse(user: $user, token: ${token.substring(0, 20)}..., needsProfileCompletion: $needsProfileCompletion)';
  }
}

class ApiUser {
  final String id;
  final String name;
  final String email;
  final String role;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    print('[ApiUser] Parsing user JSON: $json');
    
    return ApiUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'ApiUser(id: $id, name: $name, email: $email, role: $role)';
  }
}
