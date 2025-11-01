import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/points_transaction.dart';
import '../services/points_service.dart';
import '../utils/shared_preferences_service.dart';

part 'points_transactions_event.dart';
part 'points_transactions_state.dart';

class PointsTransactionsBloc extends Bloc<PointsTransactionsEvent, PointsTransactionsState> {
  PointsTransactionsBloc() : super(const PointsTransactionsState.initial()) {
    on<LoadPointsTransactions>(_onLoad);
    on<RefreshPointsTransactions>(_onRefresh);
    on<UpdatePointsTransactionsFilters>(_onUpdateFilters);
  }

  Future<void> _onLoad(LoadPointsTransactions event, Emitter<PointsTransactionsState> emit) async {
    if (SharedPreferencesService.isGuest()) {
      emit(state.copyWith(
        loading: false,
        transactions: const [],
        pagination: const PointsPagination(page: 1, limit: 20, total: 0, pages: 0),
        error: null,
      ));
      return;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      final resp = await PointsService.getTransactions(
        page: event.page ?? state.pagination.page,
        limit: event.limit ?? state.pagination.limit,
        source: state.source,
        status: state.status,
      );
      emit(state.copyWith(
        loading: false,
        transactions: resp.transactions,
        pagination: resp.pagination,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshPointsTransactions event, Emitter<PointsTransactionsState> emit) async {
    add(const LoadPointsTransactions(page: 1));
  }

  Future<void> _onUpdateFilters(UpdatePointsTransactionsFilters event, Emitter<PointsTransactionsState> emit) async {
    emit(state.copyWith(source: event.source, status: event.status));
    add(const LoadPointsTransactions(page: 1));
  }
}


