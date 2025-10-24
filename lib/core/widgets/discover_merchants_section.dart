import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant_card.dart';

class DiscoverMerchantsSection extends StatefulWidget {
  final List<MerchantCard> merchants;
  final List<String> categories;
  final Function(String)? onSearch;
  final Function(String)? onCategorySelected;

  const DiscoverMerchantsSection({
    super.key,
    required this.merchants,
    required this.categories,
    this.onSearch,
    this.onCategorySelected,
  });

  @override
  State<DiscoverMerchantsSection> createState() =>
      _DiscoverMerchantsSectionState();
}

class _DiscoverMerchantsSectionState extends State<DiscoverMerchantsSection> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              'Discover Merchants',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(26),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.white,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 34),
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    widget.onCategorySelected?.call(category);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w400
                              : FontWeight.w400, // SemiBold if selected
                          color: isSelected
                              ? AppColors.primary
                              : Color(0xff3E3E3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        width: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: widget.merchants.length,
              itemBuilder: (context, index) {
                return _buildMerchantCard(widget.merchants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(MerchantCard merchant) {
    return Container(
      // The main container no longer needs the background color,
      // border radius, or box shadow, as these visual properties
      // seem to be applied primarily to the image in the example.
      // However, we keep the margin and fixed width.
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        // The overall alignment should be centered to align the text
        // beneath the image, which appears centered in the sample.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. The Image Container (The big rounded-corner box)
          Container(
            // Set a fixed height for the image container
            height: 150, // Increased height to match the image proportion
            width: double.infinity, // Take up the full width (150)
            decoration: BoxDecoration(
              // Use a large border radius to get the pill shape corners
              borderRadius: BorderRadius.circular(16),
              // The image in the example has a dark background when not loaded,
              // or the whole card has a background. We'll use a subtle shadow
              // and maybe a background color if the image is translucent.
              color: Colors.white, // Background for the card/image container
              boxShadow: [
                // You can keep a very subtle shadow if needed, but the
                // example image's boxes look very crisp, suggesting minimal
                // or no shadow. I'll remove the complex one for simplicity.
              ],
            ),
            // ClipRRect is essential to ensure the image respects the
            // rounded corners of the BoxDecoration.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                // Using AppColors.lightGrey for the placeholder background
                color: AppColors.lightGrey,
                child: merchant.imagePath != null
                    ? Image.asset(
                        merchant.imagePath!,
                        fit: BoxFit.cover, // Ensures the image fills the area
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
          ),

          // 2. The Text Content (No additional padding or box)
          const SizedBox(height: 8), // Space between image and category text
          Text(
            merchant.category,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14, // Increased size for prominence
              fontWeight: FontWeight.w600, // Thicker font weight
              color: Colors.black, // Assuming a strong black/dark text color
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'MORE DETAIL',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.primary, // Using primary color for the link text
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Keep the placeholder image function as is, or adjust its style if necessary.
  Widget _buildPlaceholderImage() {
    // Updated to fill the space and look like the primary card style
    return Container(
      color: Colors.grey[300], // A lighter grey for the placeholder
      alignment: Alignment.center,
      child: const Icon(Icons.store, color: Colors.grey, size: 40),
    );
  }
}
