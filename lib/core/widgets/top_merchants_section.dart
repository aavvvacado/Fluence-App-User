import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';
import 'merchant_detail_modal.dart';

class TopMerchantsSection extends StatelessWidget {
  final List<Merchant> merchants;
  final VoidCallback? onViewAll;
  final bool isExpanded;

  const TopMerchantsSection({
    super.key,
    required this.merchants,
    this.onViewAll,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final showMerchants = isExpanded || merchants.length <= 3
        ? merchants
        : merchants.take(3).toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Merchants',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Color(0xff1f1f1f),
                  ),
                ),
                if (onViewAll != null && merchants.length > 3)
                  TextButton(
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Show less' : 'View all',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded ? Icons.arrow_upward : Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: showMerchants.length,
            itemBuilder: (context, index) {
              return _buildMerchantCard(context, showMerchants[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(BuildContext context, Merchant merchant) {
    return GestureDetector(
      onTap: () {
        showMerchantDetailDialog(context, merchant);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000), // #00000040
              offset: const Offset(0, 2), // x = 0, y = 2
              blurRadius: 4, // blur radius
              spreadRadius: 0, // optional, default is 0
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: merchant.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(merchant.icon, color: merchant.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  merchant.category,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff777777),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
