import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../services/merchant_search_service.dart';

/// Events for merchant search
abstract class MerchantSearchEvent extends Equatable {
  const MerchantSearchEvent();
  
  @override
  List<Object?> get props => [];
}

class SearchMerchants extends MerchantSearchEvent {
  final String query;
  final String category;
  
  const SearchMerchants({
    required this.query,
    required this.category,
  });
  
  @override
  List<Object?> get props => [query, category];
}

class ClearSearch extends MerchantSearchEvent {
  const ClearSearch();
}

/// States for merchant search
abstract class MerchantSearchState extends Equatable {
  const MerchantSearchState();
  
  @override
  List<Object?> get props => [];
}

class MerchantSearchInitial extends MerchantSearchState {}

class MerchantSearchLoading extends MerchantSearchState {}

class MerchantSearchSuccess<T> extends MerchantSearchState {
  final List<T> results;
  final String query;
  final String category;
  
  const MerchantSearchSuccess({
    required this.results,
    required this.query,
    required this.category,
  });
  
  @override
  List<Object?> get props => [results, query, category];
}

class MerchantSearchError extends MerchantSearchState {
  final String message;
  
  const MerchantSearchError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// BLoC for managing merchant search state
/// Follows Single Responsibility Principle (SRP)
class MerchantSearchBloc<T> extends Bloc<MerchantSearchEvent, MerchantSearchState> {
  final MerchantSearchService _searchService;
  final MerchantSearchMapper<T> _mapper;
  List<T> _allMerchants = [];
  
  MerchantSearchBloc({
    required MerchantSearchService searchService,
    required MerchantSearchMapper<T> mapper,
  }) : _searchService = searchService,
       _mapper = mapper,
       super(MerchantSearchInitial()) {
    on<SearchMerchants>(_onSearchMerchants);
    on<ClearSearch>(_onClearSearch);
  }
  
  /// Set the list of all merchants to search from
  void setMerchants(List<T> merchants) {
    _allMerchants = merchants;
  }
  
  Future<void> _onSearchMerchants(
    SearchMerchants event,
    Emitter<MerchantSearchState> emit,
  ) async {
    emit(MerchantSearchLoading());
    
    try {
      final results = await _searchService.search<T>(
        query: event.query,
        category: event.category,
        merchants: _allMerchants,
        mapper: _mapper,
      );
      
      emit(MerchantSearchSuccess<T>(
        results: results,
        query: event.query,
        category: event.category,
      ));
    } catch (e) {
      emit(MerchantSearchError('Search failed: ${e.toString()}'));
    }
  }
  
  void _onClearSearch(
    ClearSearch event,
    Emitter<MerchantSearchState> emit,
  ) {
    emit(MerchantSearchSuccess<T>(
      results: _allMerchants,
      query: '',
      category: 'All',
    ));
  }
}
