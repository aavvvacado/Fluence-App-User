import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';
import '../../../../core/models/merchant_post.dart';
import '../../../../core/services/api_service.dart';

class MerchantDetailScreen extends StatefulWidget {
  static const String path = '/merchants/:id';

  final Merchant merchant;

  const MerchantDetailScreen({super.key, required this.merchant});

  @override
  State<MerchantDetailScreen> createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  List<MerchantPost> _posts = [];
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _merchantDetails;

  @override
  void initState() {
    super.initState();
    if (widget.merchant.id != null) {
      _loadMerchantData();
    } else {
      setState(() {
        _loading = false;
        _error = 'Merchant ID not available';
      });
    }
  }

  Future<void> _loadMerchantData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch merchant details and posts in parallel
      final results = await Future.wait([
        ApiService.fetchMerchantDetails(widget.merchant.id!),
        ApiService.fetchMerchantPosts(widget.merchant.id!),
      ]);

      final details = results[0] as Map<String, dynamic>;
      final postsData = results[1] as List<dynamic>;

      setState(() {
        _merchantDetails = details;
        _posts = postsData
            .map(
              (post) => MerchantPost.fromJson(
                post is Map<String, dynamic> ? post : {},
              ),
            )
            .toList();
        _loading = false;
      });
    } catch (e) {
      print('[MerchantDetailScreen] Error loading data: $e');
      setState(() {
        _loading = false;
        _error = 'Failed to load merchant details';
        // Show sample data if API fails
        _posts = _getSamplePosts();
      });
    }
  }

  List<MerchantPost> _getSamplePosts() {
    // Sample data when API is not available
    return [
      MerchantPost(
        id: '1',
        merchantName: widget.merchant.name,
        merchantId: widget.merchant.id ?? '',
        userHandle: '@priya_sharma',
        userName: 'Priya Sharma',
        description: 'Amazing cappuccino and ambiance! ☕ Highly recommended!',
        imageUrl: null, // Use placeholder
        location: '19.0760, 72.8777',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
        category: widget.merchant.category,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'PostsScreen',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xffF5F5F5), // Light gray background
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _posts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.red,
                  ),
                ),
              ),
            )
          : _posts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No posts available for this merchant',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xff909090),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_posts[index]);
              },
            ),
    );
  }

  Widget _buildPostCard(MerchantPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.lightGrey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imageUrl != null
                  ? Image.network(
                      post.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
          const SizedBox(width: 16),
          // Content on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant name
                Text(
                  post.merchantName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // User handle
                if (post.userHandle != null)
                  Text(
                    post.userHandle!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff777777),
                    ),
                  ),
                const SizedBox(height: 8),
                // Description/Review
                if (post.description != null && post.description!.isNotEmpty)
                  Text(
                    post.description!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                // Location and timestamp row
                Row(
                  children: [
                    // Location
                    if (post.location != null) ...[
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xff777777),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.location!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff777777),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    // Timestamp
                    if (post.createdAt != null) ...[
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xff777777),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(post.createdAt!),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff777777),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(widget.merchant.icon, color: widget.merchant.color, size: 40),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('d MMM, hh:mm a').format(dateTime);
    } else {
      return DateFormat('d MMM, yyyy hh:mm a').format(dateTime);
    }
  }
}
