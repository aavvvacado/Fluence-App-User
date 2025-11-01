import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/points_stats.dart';
import '../services/points_service.dart';
import '../utils/shared_preferences_service.dart';

part 'points_stats_event.dart';
part 'points_stats_state.dart';

class PointsStatsBloc extends Bloc<PointsStatsEvent, PointsStatsState> {
  PointsStatsBloc() : super(const PointsStatsState.initial()) {
    on<LoadPointsStats>(_onLoadStats);
    on<RefreshPointsStats>(_onRefreshStats);
  }

  Future<void> _onLoadStats(LoadPointsStats event, Emitter<PointsStatsState> emit) async {
    if (SharedPreferencesService.isGuest()) {
      emit(state.copyWith(
        loading: false,
        stats: const PointsStats(
          totalEarned: 0,
          totalRedeemed: 0,
          currentBalance: 0,
          bySource: {},
        ),
        error: null,
      ));
      return;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      final stats = await PointsService.getStats();
      emit(state.copyWith(
        loading: false,
        stats: stats,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshStats(RefreshPointsStats event, Emitter<PointsStatsState> emit) async {
    add(const LoadPointsStats());
  }
}
