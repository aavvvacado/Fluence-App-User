import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/wallet_balance.dart';
import '../services/payment_service.dart';
import '../utils/shared_preferences_service.dart';

part 'wallet_balance_event.dart';
part 'wallet_balance_state.dart';

class WalletBalanceBloc extends Bloc<WalletBalanceEvent, WalletBalanceState> {
  WalletBalanceBloc() : super(const WalletBalanceState.initial()) {
    on<LoadWalletBalance>(_onLoadBalance);
    on<RefreshWalletBalance>(_onRefreshBalance);
  }

  Future<void> _onLoadBalance(LoadWalletBalance event, Emitter<WalletBalanceState> emit) async {
    if (SharedPreferencesService.isGuest()) {
      emit(state.copyWith(
        loading: false,
        balance: WalletBalance(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          currency: 'AED',
          lastUpdated: DateTime.now(),
        ),
        error: null,
      ));
      return;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      final balance = await PaymentService.getBalance();
      emit(state.copyWith(
        loading: false,
        balance: balance,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshBalance(RefreshWalletBalance event, Emitter<WalletBalanceState> emit) async {
    add(const LoadWalletBalance());
  }
}
