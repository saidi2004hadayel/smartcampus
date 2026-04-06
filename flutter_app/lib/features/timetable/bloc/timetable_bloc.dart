import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/timetable_repository.dart';
import '../data/timetable_model.dart';
import '../../../core/notifications/notification_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
  @override
  List<Object?> get props => [];
}

class LoadTimetableEvent extends TimetableEvent {
  final int? filterDay;
  const LoadTimetableEvent({this.filterDay});
  @override
  List<Object?> get props => [filterDay];
}

class ScheduleReminderEvent extends TimetableEvent {
  final TimetableEntry entry;
  const ScheduleReminderEvent(this.entry);
  @override
  List<Object?> get props => [entry.id];
}

class ExportTimetableEvent extends TimetableEvent {}

// ── States ────────────────────────────────────────────────────────────────────
abstract class TimetableState extends Equatable {
  const TimetableState();
  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableLoaded extends TimetableState {
  final List<TimetableEntry> entries;
  final int selectedDay;
  const TimetableLoaded(this.entries, {required this.selectedDay});
  @override
  List<Object?> get props => [entries, selectedDay];
}

class TimetableError extends TimetableState {
  final String message;
  const TimetableError(this.message);
  @override
  List<Object?> get props => [message];
}

class TimetableReminderSet extends TimetableState {
  final String courseName;
  const TimetableReminderSet(this.courseName);
  @override
  List<Object?> get props => [courseName];
}

class TimetableExported extends TimetableState {
  final String jsonContent;
  const TimetableExported(this.jsonContent);
  @override
  List<Object?> get props => [jsonContent];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repo;
  final NotificationService _notifications;
  List<TimetableEntry> _allEntries = [];
  int _currentDay = DateTime.now().weekday - 1;

  TimetableBloc(this._repo, this._notifications) : super(TimetableInitial()) {
    on<LoadTimetableEvent>(_onLoad);
    on<ScheduleReminderEvent>(_onScheduleReminder);
    on<ExportTimetableEvent>(_onExport);
  }

  Future<void> _onLoad(
      LoadTimetableEvent event, Emitter<TimetableState> emit) async {
    emit(TimetableLoading());
    try {
      _allEntries = await _repo.getTimetable();
      _currentDay = event.filterDay ?? (DateTime.now().weekday - 1);
      final filtered =
      _allEntries.where((e) => e.dayOfWeek == _currentDay).toList();
      emit(TimetableLoaded(filtered, selectedDay: _currentDay));
    } catch (e) {
      emit(const TimetableError('Failed to load timetable'));
    }
  }

  Future<void> _onScheduleReminder(
      ScheduleReminderEvent event, Emitter<TimetableState> emit) async {
    final entry = event.entry;
    await _notifications.scheduleClassReminder(
      id: entry.id.hashCode,
      courseName: entry.courseName,
      room: entry.room,
      classTime: entry.nextOccurrence,
      minutesBefore: 10,
    );
    emit(TimetableReminderSet(entry.courseName));
    final filtered =
    _allEntries.where((e) => e.dayOfWeek == _currentDay).toList();
    emit(TimetableLoaded(filtered, selectedDay: _currentDay));
  }

  Future<void> _onExport(
      ExportTimetableEvent event, Emitter<TimetableState> emit) async {
    try {
      final json = await _repo.exportAsJson();
      emit(TimetableExported(json));
    } catch (e) {
      emit(const TimetableError('Export failed'));
    }
  }
}