part of 'points_stats_bloc.dart';

class PointsStatsState extends Equatable {
  final bool loading;
  final PointsStats? stats;
  final String? error;

  const PointsStatsState({
    required this.loading,
    this.stats,
    this.error,
  });

  const PointsStatsState.initial()
      : loading = false,
        stats = null,
        error = null;

  PointsStatsState copyWith({
    bool? loading,
    PointsStats? stats,
    String? error,
  }) {
    return PointsStatsState(
      loading: loading ?? this.loading,
      stats: stats ?? this.stats,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, stats, error];
}
