class Notification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.message == message &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        title.hashCode ^
        message.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Notification(id: $id, type: $type, title: $title, message: $message, isRead: $isRead, createdAt: $createdAt)';
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'pages': pages,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pagination &&
        other.page == page &&
        other.limit == limit &&
        other.total == total &&
        other.pages == pages;
  }

  @override
  int get hashCode {
    return page.hashCode ^ limit.hashCode ^ total.hashCode ^ pages.hashCode;
  }

  @override
  String toString() {
    return 'Pagination(page: $page, limit: $limit, total: $total, pages: $pages)';
  }
}

class NotificationResponse {
  final List<Notification> notifications;
  final Pagination pagination;

  const NotificationResponse({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['notifications'] as List? ?? [])
          .map((item) => Notification.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationResponse &&
        other.notifications == notifications &&
        other.pagination == pagination;
  }

  @override
  int get hashCode {
    return notifications.hashCode ^ pagination.hashCode;
  }

  @override
  String toString() {
    return 'NotificationResponse(notifications: $notifications, pagination: $pagination)';
  }
}

class UnreadCountResponse {
  final int unreadCount;

  const UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unreadCount': unreadCount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnreadCountResponse && other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => unreadCount.hashCode;

  @override
  String toString() {
    return 'UnreadCountResponse(unreadCount: $unreadCount)';
  }
}
