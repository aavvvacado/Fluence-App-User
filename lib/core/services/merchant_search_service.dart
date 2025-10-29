/// Service responsible for searching merchants
/// Follows Single Responsibility Principle (SRP)
abstract class MerchantSearchService {
  /// Search merchants by query and category
  /// Returns filtered list of merchants
  Future<List<T>> search<T>({
    required String query,
    required String category,
    required List<T> merchants,
    required MerchantSearchMapper<T> mapper,
  });
}

/// Mapper interface for converting merchant data to searchable format
/// Follows Interface Segregation Principle (ISP)
abstract class MerchantSearchMapper<T> {
  /// Get searchable text from merchant object
  String getSearchableText(T merchant);
  
  /// Get category from merchant object
  String getCategory(T merchant);
}

/// Implementation of merchant search service
/// Follows Open/Closed Principle (OCP) - open for extension, closed for modification
class MerchantSearchServiceImpl implements MerchantSearchService {
  @override
  Future<List<T>> search<T>({
    required String query,
    required String category,
    required List<T> merchants,
    required MerchantSearchMapper<T> mapper,
  }) async {
    // Simulate API delay for realistic behavior
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.isEmpty && category == 'All') {
      return merchants;
    }
    
    return merchants.where((merchant) {
      final searchableText = mapper.getSearchableText(merchant).toLowerCase();
      final merchantCategory = mapper.getCategory(merchant);
      final searchQuery = query.toLowerCase();
      
      // Filter by category first
      final categoryMatch = category == 'All' || merchantCategory == category;
      
      // Filter by search query
      final queryMatch = searchQuery.isEmpty || searchableText.contains(searchQuery);
      
      return categoryMatch && queryMatch;
    }).toList();
  }
}
