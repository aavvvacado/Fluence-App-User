import 'package:equatable/equatable.dart';

class WalletBalance extends Equatable {
  final double totalBalance;
  final double availableBalance;
  final double pendingBalance;
  final String currency;
  final DateTime lastUpdated;

  const WalletBalance({
    required this.totalBalance,
    required this.availableBalance,
    required this.pendingBalance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return WalletBalance(
      totalBalance: (data['totalBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (data['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (data['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      currency: (data['currency'] ?? '').toString(),
      lastUpdated:
          DateTime.tryParse((data['lastUpdated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'totalBalance': totalBalance,
        'availableBalance': availableBalance,
        'pendingBalance': pendingBalance,
        'currency': currency,
        'lastUpdated': lastUpdated.toIso8601String(),
      },
    };
  }

  @override
  List<Object?> get props => [
    totalBalance,
    availableBalance,
    pendingBalance,
    currency,
    lastUpdated,
  ];
}
