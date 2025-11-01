part of 'points_stats_bloc.dart';

abstract class PointsStatsEvent extends Equatable {
  const PointsStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPointsStats extends PointsStatsEvent {
  const LoadPointsStats();
}

class RefreshPointsStats extends PointsStatsEvent {
  const RefreshPointsStats();
}
