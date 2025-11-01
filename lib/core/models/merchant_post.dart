class MerchantPost {
  final String id;
  final String merchantName;
  final String merchantId;
  final String? userHandle;
  final String? userName;
  final String? description;
  final String? imageUrl;
  final String? location; // coordinates or address
  final DateTime? createdAt;
  final String? category;

  const MerchantPost({
    required this.id,
    required this.merchantName,
    required this.merchantId,
    this.userHandle,
    this.userName,
    this.description,
    this.imageUrl,
    this.location,
    this.createdAt,
    this.category,
  });

  factory MerchantPost.fromJson(Map<String, dynamic> json) {
    return MerchantPost(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      merchantName: json['merchantName'] ?? json['merchant_name'] ?? '',
      merchantId: json['merchantId']?.toString() ?? json['merchant_id']?.toString() ?? '',
      userHandle: json['userHandle'] ?? json['user_handle'] ?? json['username'],
      userName: json['userName'] ?? json['user_name'],
      description: json['description'] ?? json['text'] ?? json['review'],
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
      location: json['location'] ?? json['coordinates']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      category: json['category'] ?? json['merchantCategory'],
    );
  }
}

