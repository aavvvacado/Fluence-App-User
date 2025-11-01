class MerchantCard {
  final String businessName;
  final String category; // mapped from businessType
  final String? contactEmail;
  final String? description;
  final String? imageUrl; // optional future proofing

  const MerchantCard({
    required this.businessName,
    required this.category,
    this.contactEmail,
    this.description,
    this.imageUrl,
  });
}
