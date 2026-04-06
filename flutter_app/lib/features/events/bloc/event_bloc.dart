import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/event_repository.dart';
import '../data/event_model.dart';
import '../../../core/network/connectivity_service.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override List<Object?> get props => [];
}
class LoadEventsEvent extends EventEvent { const LoadEventsEvent(); }

abstract class EventState extends Equatable {
  final bool isOffline;
  const EventState({this.isOffline = false});
  @override List<Object?> get props => [isOffline];
}
class EventInitial extends EventState {}
class EventLoading extends EventState {}
class EventLoaded extends EventState {
  final List<CampusEvent> items;
  const EventLoaded(this.items, {super.isOffline});
  @override List<Object?> get props => [items, isOffline];
}
class EventError extends EventState {
  final String message;
  const EventError(this.message);
}

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repo;
  final ConnectivityService _connectivity;
  EventBloc(this._repo, this._connectivity) : super(EventInitial()) {
    on<LoadEventsEvent>((_, emit) async {
      emit(EventLoading());
      try {
        final items = await _repo.getEvents();
        emit(EventLoaded(items, isOffline: !_connectivity.isOnline));
      } catch (e) {
        emit(EventError('Failed to load events'));
      }
    });
  }
}
