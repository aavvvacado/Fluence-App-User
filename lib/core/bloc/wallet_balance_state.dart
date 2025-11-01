part of 'wallet_balance_bloc.dart';

class WalletBalanceState extends Equatable {
  final bool loading;
  final WalletBalance? balance;
  final String? error;

  const WalletBalanceState({
    required this.loading,
    this.balance,
    this.error,
  });

  const WalletBalanceState.initial()
      : loading = false,
        balance = null,
        error = null;

  WalletBalanceState copyWith({
    bool? loading,
    WalletBalance? balance,
    String? error,
  }) {
    return WalletBalanceState(
      loading: loading ?? this.loading,
      balance: balance ?? this.balance,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, balance, error];
}
