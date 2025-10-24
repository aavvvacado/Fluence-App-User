class PromoItem {
  final String name;
  final String currentPrice;
  final String originalPrice;
  final String? imagePath;

  const PromoItem({
    required this.name,
    required this.currentPrice,
    required this.originalPrice,
    this.imagePath,
  });
}
