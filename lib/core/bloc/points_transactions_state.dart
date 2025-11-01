part of 'points_transactions_bloc.dart';

class PointsTransactionsState extends Equatable {
  final bool loading;
  final List<PointsTransaction> transactions;
  final PointsPagination pagination;
  final String? source;
  final String? status;
  final String? error;

  const PointsTransactionsState({
    required this.loading,
    required this.transactions,
    required this.pagination,
    this.source,
    this.status,
    this.error,
  });

  const PointsTransactionsState.initial()
      : loading = false,
        transactions = const [],
        pagination = const PointsPagination(page: 1, limit: 20, total: 0, pages: 0),
        source = null,
        status = null,
        error = null;

  PointsTransactionsState copyWith({
    bool? loading,
    List<PointsTransaction>? transactions,
    PointsPagination? pagination,
    String? source,
    String? status,
    String? error,
  }) {
    return PointsTransactionsState(
      loading: loading ?? this.loading,
      transactions: transactions ?? this.transactions,
      pagination: pagination ?? this.pagination,
      source: source ?? this.source,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, transactions, pagination, source, status, error];
}


