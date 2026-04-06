import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/announcement_repository.dart';
import '../data/announcement_model.dart';
import '../../../core/network/connectivity_service.dart';

// Events
abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();
  @override List<Object?> get props => [];
}
class LoadAnnouncementsEvent extends AnnouncementEvent {
  final bool forceRefresh;
  const LoadAnnouncementsEvent({this.forceRefresh = false});
}

// States
abstract class AnnouncementState extends Equatable {
  final bool isOffline;
  const AnnouncementState({this.isOffline = false});
  @override List<Object?> get props => [isOffline];
}
class AnnouncementInitial extends AnnouncementState {}
class AnnouncementLoading extends AnnouncementState {}
class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> items;
  const AnnouncementLoaded(this.items, {super.isOffline});
  @override List<Object?> get props => [items, isOffline];
}
class AnnouncementError extends AnnouncementState {
  final String message;
  const AnnouncementError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repo;
  final ConnectivityService _connectivity;

  AnnouncementBloc(this._repo, this._connectivity) : super(AnnouncementInitial()) {
    on<LoadAnnouncementsEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadAnnouncementsEvent event, Emitter<AnnouncementState> emit) async {
    emit(AnnouncementLoading());
    try {
      final items = await _repo.getAnnouncements(forceRefresh: event.forceRefresh);
      emit(AnnouncementLoaded(items, isOffline: !_connectivity.isOnline));
    } catch (e) {
      emit(AnnouncementError('Failed to load announcements'));
    }
  }
}
