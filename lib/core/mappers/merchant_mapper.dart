import '../models/merchant.dart';
import '../services/merchant_search_service.dart';

/// Mapper for Merchant to searchable format
/// Follows Single Responsibility Principle (SRP)
class MerchantMapper implements MerchantSearchMapper<Merchant> {
  @override
  String getSearchableText(Merchant merchant) {
    return '${merchant.name} ${merchant.category}';
  }
  
  @override
  String getCategory(Merchant merchant) {
    return merchant.category;
  }
}
