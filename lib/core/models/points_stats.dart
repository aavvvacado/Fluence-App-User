import 'package:equatable/equatable.dart';

class PointsStats extends Equatable {
  final int totalEarned;
  final int totalRedeemed;
  final int currentBalance;
  final Map<String, int> bySource;

  const PointsStats({
    required this.totalEarned,
    required this.totalRedeemed,
    required this.currentBalance,
    required this.bySource,
  });

  factory PointsStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final bySourceData = data['bySource'] as Map<String, dynamic>? ?? {};
    
    return PointsStats(
      totalEarned: (data['totalEarned'] as num?)?.toInt() ?? 0,
      totalRedeemed: (data['totalRedeemed'] as num?)?.toInt() ?? 0,
      currentBalance: (data['currentBalance'] as num?)?.toInt() ?? 0,
      bySource: bySourceData.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'totalEarned': totalEarned,
        'totalRedeemed': totalRedeemed,
        'currentBalance': currentBalance,
        'bySource': bySource,
      },
    };
  }

  @override
  List<Object?> get props => [totalEarned, totalRedeemed, currentBalance, bySource];
}
