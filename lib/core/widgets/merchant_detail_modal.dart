import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';

/// ✅ Shows merchant detail as a clean, square popup dialog that dismisses when clicking outside
void showMerchantDetailDialog(BuildContext context, Merchant merchant) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      final dialogSide = size.width < size.height
          ? size.width * 0.8
          : size.height * 0.8;

      return Stack(
        children: [
          // 👇 Tap outside to dismiss
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // 👇 Centered dialog box (absorbs inner taps)
          Center(
            child: GestureDetector(
              onTap: () {}, // absorbs only inner taps
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: dialogSide,
                  height: dialogSide,
                  color: Colors.white,
                  child: MerchantDetailModal(
                    merchant: merchant,
                    showTitle: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class MerchantDetailModal extends StatefulWidget {
  final Merchant merchant;
  final bool showTitle;

  const MerchantDetailModal({
    super.key,
    required this.merchant,
    this.showTitle = true,
  });

  @override
  State<MerchantDetailModal> createState() => _MerchantDetailModalState();
}

class _MerchantDetailModalState extends State<MerchantDetailModal> {
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
        _error = null;
      });
    }
  }

  Future<void> _loadMerchantData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final details = await ApiService.fetchMerchantDetails(
        widget.merchant.id!,
      );
      setState(() {
        _merchantDetails = details;
        _loading = false;
      });
    } catch (e) {
      print('[MerchantDetailModal] Error loading data: $e');
      setState(() {
        _loading = false;
        _error = 'Failed to load merchant details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
        ),
      );
    }

    final details = _merchantDetails ?? {};
    final businessName =
        (details['businessName'] ??
                details['name'] ??
                widget.merchant.name ??
                '')
            .toString();
    final businessType =
        (details['businessType'] ??
                details['category'] ??
                widget.merchant.category ??
                '')
            .toString();
    final contactEmail = (details['contactEmail'] ?? details['email'] ?? '')
        .toString();
    final description =
        (details['businessDescription'] ?? details['description'] ?? '')
            .toString();

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.lightGrey,
                  ),
                  child: _buildPlaceholderImage(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      if (contactEmail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Color(0xff777777),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                contactEmail,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff777777),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (businessType.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                businessType,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'About',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(widget.merchant.icon, color: widget.merchant.color, size: 40),
    );
  }
}
