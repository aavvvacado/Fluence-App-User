import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/promo_item.dart';

class DiscountPromoSection extends StatelessWidget {
  final List<PromoItem> promoItems;

  const DiscountPromoSection({super.key, required this.promoItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Discount and Promo',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: promoItems.length,
            itemBuilder: (context, index) {
              return _buildPromoItem(promoItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoItem(PromoItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffC48828),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item.currentPrice,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffC48828),
                      ),
                    ),
                    if (item.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.originalPrice,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCECECE).withOpacity(0.85),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.lightGrey,
      child: const Icon(
        Icons.card_giftcard,
        color: AppColors.textBody,
        size: 30,
      ),
    );
  }
}
