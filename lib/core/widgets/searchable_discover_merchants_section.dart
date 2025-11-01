import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/guest/presentation/guest_guard.dart';
import '../bloc/merchant_search_bloc.dart';
import '../constants/app_colors.dart';
import '../mappers/merchant_card_mapper.dart';
import '../models/merchant.dart';
import '../models/merchant_card.dart';
import '../services/merchant_search_service.dart';
import 'merchant_detail_modal.dart';

/// Enhanced discover merchants section with search functionality
/// Follows Single Responsibility Principle (SRP)
class SearchableDiscoverMerchantsSection extends StatefulWidget {
  final List<MerchantCard> merchants;
  final List<String> categories;
  final VoidCallback? onMerchantTap;

  const SearchableDiscoverMerchantsSection({
    super.key,
    required this.merchants,
    required this.categories,
    this.onMerchantTap,
  });

  @override
  State<SearchableDiscoverMerchantsSection> createState() =>
      _SearchableDiscoverMerchantsSectionState();
}

class _SearchableDiscoverMerchantsSectionState
    extends State<SearchableDiscoverMerchantsSection> {
  final TextEditingController _searchController = TextEditingController();
  final MerchantSearchBloc<MerchantCard> _searchBloc =
      MerchantSearchBloc<MerchantCard>(
        searchService: MerchantSearchServiceImpl(),
        mapper: MerchantCardMapper(),
      );
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchBloc.setMerchants(widget.merchants);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant SearchableDiscoverMerchantsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.merchants != widget.merchants) {
      // Update source list when new data arrives
      _searchBloc.setMerchants(widget.merchants);
      // Re-run current filter to avoid empty state on category tap
      _searchBloc.add(
        SearchMerchants(
          query: _searchController.text,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchBloc.add(
      SearchMerchants(
        query: _searchController.text,
        category: _selectedCategory,
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _searchBloc.add(
      SearchMerchants(query: _searchController.text, category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Container(
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
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildMerchantsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(26),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search merchants...',
            hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.white),
            prefixIcon: Icon(Icons.search, color: AppColors.white),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
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
              if (isGuestUser()) {
                showSignInRequiredSheet(context);
                return;
              }
              _onCategorySelected(category);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xff3E3E3E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  width: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMerchantsList() {
    return BlocBuilder<MerchantSearchBloc<MerchantCard>, MerchantSearchState>(
      builder: (context, state) {
        if (state is MerchantSearchLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is MerchantSearchError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        List<MerchantCard> merchants = widget.merchants;
        if (state is MerchantSearchSuccess<MerchantCard>) {
          merchants = state.results;
        }

        if (merchants.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No merchants found',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: merchants.length,
            itemBuilder: (context, index) {
              return _buildMerchantCard(merchants[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMerchantCard(MerchantCard merchant) {
    return GestureDetector(
      onTap: () {
        if (isGuestUser()) {
          showSignInRequiredSheet(context);
          return;
        }
        // Show the same detail dialog used elsewhere, mapping MerchantCard -> Merchant
        final placeholder = Merchant(
          id: null, // no id available from discover card
          name: merchant.businessName,
          category: merchant.category,
          icon: Icons.store,
          color: AppColors.primary,
        );
        showMerchantDetailDialog(context, placeholder);
        widget.onMerchantTap?.call();
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.lightGrey,
                  child: merchant.imageUrl != null
                      ? Image.network(
                          merchant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              merchant.businessName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                if (isGuestUser()) {
                  showSignInRequiredSheet(context);
                  return;
                }
                _showMerchantDetail(merchant);
              },
              child: const Text(
                'MORE DETAIL',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMerchantDetail(MerchantCard merchant) {
    final placeholder = Merchant(
      id: null,
      name: merchant.businessName,
      category: merchant.category,
      icon: Icons.store,
      color: AppColors.primary,
    );
    showMerchantDetailDialog(context, placeholder);
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.store, color: Colors.grey, size: 40),
    );
  }
}
