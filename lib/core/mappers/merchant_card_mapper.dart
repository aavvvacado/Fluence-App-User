import '../models/merchant_card.dart';
import '../services/merchant_search_service.dart';

/// Mapper for MerchantCard to searchable format
/// Follows Single Responsibility Principle (SRP)
class MerchantCardMapper implements MerchantSearchMapper<MerchantCard> {
  @override
  String getSearchableText(MerchantCard merchant) {
    final parts = [
      merchant.businessName,
      merchant.category,
      merchant.contactEmail ?? '',
      merchant.description ?? '',
    ];
    return parts.where((e) => e.isNotEmpty).join(' ');
  }
  
  @override
  String getCategory(MerchantCard merchant) {
    return merchant.category;
  }
}
