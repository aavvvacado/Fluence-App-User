import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/shared_preferences_service.dart';

// Events
abstract class GuestEvent extends Equatable {
  const GuestEvent();
  @override
  List<Object?> get props => [];
}

class GuestLoginRequested extends GuestEvent {
  final String deviceId;
  const GuestLoginRequested(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class GuestSessionRestored extends GuestEvent {
  const GuestSessionRestored();
}

class GuestLogoutRequested extends GuestEvent {
  const GuestLogoutRequested();
}

// States
abstract class GuestState extends Equatable {
  const GuestState();
  @override
  List<Object?> get props => [];
}

class GuestInitial extends GuestState {}
class GuestLoading extends GuestState {}
class GuestNone extends GuestState {}

class GuestAuthenticated extends GuestState {
  final String guestId;
  final String token;
  const GuestAuthenticated({required this.guestId, required this.token});
  @override
  List<Object?> get props => [guestId, token];
}

class GuestError extends GuestState {
  final String message;
  const GuestError(this.message);
  @override
  List<Object?> get props => [message];
}

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  GuestBloc() : super(GuestInitial()) {
    on<GuestSessionRestored>(_onRestore);
    on<GuestLoginRequested>(_onLogin);
    on<GuestLogoutRequested>(_onLogout);
  }

  Future<void> _onRestore(GuestSessionRestored event, Emitter<GuestState> emit) async {
    final token = SharedPreferencesService.getGuestToken();
    final id = SharedPreferencesService.getGuestId();
    if (token != null && id != null) {
      emit(GuestAuthenticated(guestId: id, token: token));
    } else {
      emit(GuestNone());
    }
  }

  Future<void> _onLogin(GuestLoginRequested event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final resp = await ApiService.guestLogin(deviceId: event.deviceId);
      // Accept any shape that returns a non-empty token
      final token = (resp['token'] as String?) ?? '';
      if (token.isNotEmpty) {
        // Use provided guestId if present; else fall back to deviceId or 'guest'
        final providedGuestId = (resp['guestId'] as String?) ?? event.deviceId;
        await SharedPreferencesService.saveGuestSession(
          guestId: providedGuestId,
          token: token,
        );
        emit(GuestAuthenticated(guestId: providedGuestId, token: token));
      } else {
        emit(const GuestError('Guest login failed: empty token'));
      }
    } catch (e) {
      emit(GuestError('Guest login error: $e'));
    }
  }

  Future<void> _onLogout(GuestLogoutRequested event, Emitter<GuestState> emit) async {
    await SharedPreferencesService.clearGuestSession();
    emit(GuestNone());
  }
}


