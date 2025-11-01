import 'package:equatable/equatable.dart';

class PointsTransaction extends Equatable {
  final String id;
  final int points;
  final String source;
  final String description;
  final String status;
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.points,
    required this.source,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    final dynamic pointsValue = json['points'] ?? json['amount'];
    final String sourceValue = (json['source'] ?? json['transaction_type'] ?? '').toString();
    final String createdAtRaw = (json['createdAt'] ?? json['created_at'] ?? '').toString();
    return PointsTransaction(
      id: (json['id'] ?? '').toString(),
      points: (pointsValue is num)
          ? pointsValue.toInt()
          : int.tryParse(pointsValue?.toString() ?? '') ?? 0,
      source: sourceValue,
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, points, source, description, status, createdAt];
}

class PointsPagination extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PointsPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PointsPagination.fromJson(Map<String, dynamic>? json) {
    return PointsPagination(
      page: (json?['page'] as num?)?.toInt() ?? 1,
      limit: (json?['limit'] as num?)?.toInt() ?? 10,
      total: (json?['total'] as num?)?.toInt() ?? 0,
      pages: (json?['pages'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [page, limit, total, pages];
}

class PointsTransactionsResponse extends Equatable {
  final List<PointsTransaction> transactions;
  final PointsPagination pagination;

  const PointsTransactionsResponse({
    required this.transactions,
    required this.pagination,
  });

  factory PointsTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'];
    List<PointsTransaction> txs = const [];
    PointsPagination pagination = const PointsPagination(page: 1, limit: 20, total: 0, pages: 0);

    if (dataNode is List) {
      txs = dataNode
          .whereType<Map<String, dynamic>>()
          .map((e) => PointsTransaction.fromJson(e))
          .toList();
      pagination = PointsPagination(
        page: 1,
        limit: txs.length,
        total: txs.length,
        pages: 1,
      );
    } else if (dataNode is Map<String, dynamic>) {
      txs = (dataNode['transactions'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => PointsTransaction.fromJson(e))
          .toList();
      pagination = PointsPagination.fromJson(dataNode['pagination'] as Map<String, dynamic>?);
    }

    return PointsTransactionsResponse(transactions: txs, pagination: pagination);
  }

  @override
  List<Object?> get props => [transactions, pagination];
}


