part of 'points_transactions_bloc.dart';

abstract class PointsTransactionsEvent extends Equatable {
  const PointsTransactionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadPointsTransactions extends PointsTransactionsEvent {
  final int? page;
  final int? limit;
  const LoadPointsTransactions({this.page, this.limit});
}

class RefreshPointsTransactions extends PointsTransactionsEvent {
  const RefreshPointsTransactions();
}

class UpdatePointsTransactionsFilters extends PointsTransactionsEvent {
  final String? source;
  final String? status;
  const UpdatePointsTransactionsFilters({this.source, this.status});

  @override
  List<Object?> get props => [source, status];
}


