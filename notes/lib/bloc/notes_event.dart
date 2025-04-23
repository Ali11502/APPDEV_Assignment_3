// Events
import 'package:equatable/equatable.dart';

import '../models/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final String title;
  final String content;
  final String category;

  const AddNote({
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  List<Object> get props => [title, content, category];
}

class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote({required this.note});

  @override
  List<Object> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String id;

  const DeleteNote({required this.id});

  @override
  List<Object> get props => [id];
}

// States
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded({this.notes = const <Note>[]});

  @override
  List<Object> get props => [notes];
}

class NotesError extends NotesState {
  final String message;

  const NotesError({required this.message});

  @override
  List<Object> get props => [message];
}