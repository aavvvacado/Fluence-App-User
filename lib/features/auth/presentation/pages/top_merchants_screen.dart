import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';
import '../../../../core/widgets/merchant_detail_modal.dart';

class TopMerchantsScreen extends StatefulWidget {
  static const String path = '/merchants/top';

  final List<Merchant> merchants;

  const TopMerchantsScreen({super.key, required this.merchants});

  @override
  State<TopMerchantsScreen> createState() => _TopMerchantsScreenState();
}

class _TopMerchantsScreenState extends State<TopMerchantsScreen> {
  String _query = '';

  List<Merchant> get _filtered => _query.trim().isEmpty
      ? widget.merchants
      : widget.merchants
          .where((m) =>
              m.name.toLowerCase().contains(_query.toLowerCase()) ||
              m.category.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Top Merchants',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search merchants',
                hintStyle: const TextStyle(fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: const Color(0xffF4F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No merchants found',
                      style: TextStyle(fontFamily: 'Poppins', color: Color(0xff909090)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) => _MerchantCard(merchant: _filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final Merchant merchant;
  const _MerchantCard({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMerchantDetailDialog(context, merchant);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000),
              offset: const Offset(0, 2),
              blurRadius: 4,
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
