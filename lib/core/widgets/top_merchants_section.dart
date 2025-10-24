import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';

class TopMerchantsSection extends StatelessWidget {
  final List<Merchant> merchants;
  final VoidCallback? onViewAll;

  const TopMerchantsSection({
    super.key,
    required this.merchants,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
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
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,

                            height: 1,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
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
            itemCount: merchants.length,
            itemBuilder: (context, index) {
              return _buildMerchantCard(merchants[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return Container(
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
    );
  }
}
