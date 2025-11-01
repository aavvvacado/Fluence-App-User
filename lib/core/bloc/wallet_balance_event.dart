part of 'wallet_balance_bloc.dart';

abstract class WalletBalanceEvent extends Equatable {
  const WalletBalanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletBalance extends WalletBalanceEvent {
  const LoadWalletBalance();
}

class RefreshWalletBalance extends WalletBalanceEvent {
  const RefreshWalletBalance();
}
