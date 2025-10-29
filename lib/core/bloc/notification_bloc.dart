import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/notification.dart';
import '../services/notification_service.dart';

/// Events for notification management
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int page;
  final int limit;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool refresh;

  const LoadNotifications({
    this.page = 1,
    this.limit = 10,
    this.type,
    this.startDate,
    this.endDate,
    this.refresh = false,
  });
  
  @override
  List<Object?> get props => [page, limit, type, startDate, endDate, refresh];
}

class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;
  
  const MarkAsRead(this.notificationId);
  
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

/// States for notification management
abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  final Pagination pagination;
  final int unreadCount;
  final bool hasMore;
  
  const NotificationLoaded({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
    required this.hasMore,
  });
  
  @override
  List<Object?> get props => [notifications, pagination, unreadCount, hasMore];
}

class NotificationError extends NotificationState {
  final String message;
  
  const NotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UnreadCountLoaded extends NotificationState {
  final int unreadCount;
  
  const UnreadCountLoaded(this.unreadCount);
  
  @override
  List<Object?> get props => [unreadCount];
}

class UnreadCountError extends NotificationState {
  final String message;
  
  const UnreadCountError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class NotificationMarkedAsRead extends NotificationState {
  final String notificationId;
  
  const NotificationMarkedAsRead(this.notificationId);
  
  @override
  List<Object?> get props => [notificationId];
}

class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

class NotificationDeleted extends NotificationState {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RefreshNotifications>(_onRefreshNotifications);
  }
  
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(NotificationLoading());
      } else if (state is NotificationLoaded) {
        // If we're loading more notifications, keep the current state
        final currentState = state as NotificationLoaded;
        if (event.page > currentState.pagination.page) {
          // Loading more - don't show loading state
        } else {
          emit(NotificationLoading());
        }
      } else {
        emit(NotificationLoading());
      }
      
      final notificationResponse = await NotificationService.getNotifications(
        page: event.page,
        limit: event.limit,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      // Get unread count
      int unreadCount = 0;
      try {
        unreadCount = await NotificationService.getUnreadCount();
      } catch (e) {
        print('[NotificationBloc] Failed to load unread count: $e');
        // Don't fail the whole operation if unread count fails
      }
      
      List<Notification> notifications;
      if (event.page == 1 || event.refresh) {
        // First page or refresh - replace notifications
        notifications = notificationResponse.notifications;
      } else {
        // Loading more - append to existing notifications
        final currentState = state as NotificationLoaded;
        notifications = [...currentState.notifications, ...notificationResponse.notifications];
      }
      
      final hasMore = notificationResponse.pagination.page < notificationResponse.pagination.pages;
      
      emit(NotificationLoaded(
        notifications: notifications,
        pagination: notificationResponse.pagination,
        unreadCount: unreadCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await NotificationService.getUnreadCount();
      emit(UnreadCountLoaded(unreadCount));
    } catch (e) {
      emit(UnreadCountError('Failed to load unread count: ${e.toString()}'));
    }
  }
  
  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('[NotificationBloc] Marking notification ${event.notificationId} as read');
      await NotificationService.markAsRead(event.notificationId);
      
      // Update the notification in the current state if it exists
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        print('[NotificationBloc] Current notifications count: ${currentState.notifications.length}');
        print('[NotificationBloc] Current unread count: ${currentState.unreadCount}');
        
        final updatedNotifications = currentState.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            print('[NotificationBloc] Found notification to mark as read: ${notification.title}');
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        // Decrease unread count
        final newUnreadCount = currentState.unreadCount > 0 
            ? currentState.unreadCount - 1 
            : 0;
        
        print('[NotificationBloc] New unread count: $newUnreadCount');
        print('[NotificationBloc] Updated notifications count: ${updatedNotifications.length}');
        
        emit(NotificationLoaded(
          notifications: updatedNotifications,
          pagination: currentState.pagination,
          unreadCount: newUnreadCount,
          hasMore: currentState.hasMore,
        ));
      }
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: ${e.toString()}'));
    }
  }
  
  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await NotificationService.markAllAsRead();
      
      // Update all notifications in the current state to read
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        
        emit(NotificationLoaded(
          notifications: updatedNotifications,
          pagination: currentState.pagination,
          unreadCount: 0,
          hasMore: currentState.hasMore,
        ));
      }
      
      emit(const AllNotificationsMarkedAsRead());
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('[NotificationBloc] Deleting notification ${event.notificationId}');
      await NotificationService.deleteNotification(event.notificationId);

      // Update the current state by removing the deleted notification
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        print('[NotificationBloc] Current notifications count: ${currentState.notifications.length}');
        print('[NotificationBloc] Current unread count: ${currentState.unreadCount}');
        
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        // Update unread count if the deleted notification was unread
        final deletedNotification = currentState.notifications
            .firstWhere((n) => n.id == event.notificationId);
        final newUnreadCount = deletedNotification.isRead
            ? currentState.unreadCount
            : (currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0);

        print('[NotificationBloc] Deleted notification was read: ${deletedNotification.isRead}');
        print('[NotificationBloc] New unread count: $newUnreadCount');
        print('[NotificationBloc] Updated notifications count: ${updatedNotifications.length}');

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            pagination: currentState.pagination,
            unreadCount: newUnreadCount,
            hasMore: currentState.hasMore,
          ),
        );
      }
    } catch (e) {
      print('[NotificationBloc] Error deleting notification: $e');
      emit(
        NotificationError(
          'Failed to delete notification: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Trigger a refresh by loading the first page
    add(const LoadNotifications(page: 1, refresh: true));
  }
}