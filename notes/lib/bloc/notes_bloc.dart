import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_event.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';
import 'package:uuid/uuid.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _notesRepository = NotesRepository();

  NotesBloc() : super(NotesLoading()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  FutureOr<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());

      // Load notes from SharedPreferences
      final notes = await _notesRepository.loadNotes();

      // If no saved notes, add sample notes
      if (notes.isEmpty) {
        final sampleNotes = _createSampleNotes();
        await _notesRepository.saveNotes(sampleNotes);
        emit(NotesLoaded(notes: sampleNotes));
      } else {
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  FutureOr<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      final currentState = state;
      if (currentState is NotesLoaded) {
        // Validate inputs
        if (event.title.trim().isEmpty || event.content.trim().isEmpty) {
          emit(const NotesError(message: 'Title and content cannot be empty'));
          emit(currentState); // Emit back the current state to continue
          return;
        }

        final newNote = Note(
          id: const Uuid().v4(),
          title: event.title,
          content: event.content,
          category: event.category,
          createdAt: DateTime.now(),
        );

        final updatedNotes = [...currentState.notes, newNote];

        // Save to SharedPreferences
        await _notesRepository.saveNotes(updatedNotes);

        emit(NotesLoaded(notes: updatedNotes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
      if (state is NotesLoaded) {
        emit(state);
      } else {
        emit(NotesLoaded(notes: const []));
      }
    }
  }

  FutureOr<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      final currentState = state;
      if (currentState is NotesLoaded) {
        // Validate inputs
        if (event.note.title.trim().isEmpty || event.note.content.trim().isEmpty) {
          emit(const NotesError(message: 'Title and content cannot be empty'));
          emit(currentState); // Emit back the current state to continue
          return;
        }

        final updatedNotes = currentState.notes.map((note) {
          return note.id == event.note.id ? event.note : note;
        }).toList();

        // Save to SharedPreferences
        await _notesRepository.saveNotes(updatedNotes);

        emit(NotesLoaded(notes: updatedNotes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
      if (state is NotesLoaded) {
        emit(state);
      }
    }
  }

  FutureOr<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      final currentState = state;
      if (currentState is NotesLoaded) {
        final filteredNotes = currentState.notes.where(
                (note) => note.id != event.id
        ).toList();

        // Save to SharedPreferences
        await _notesRepository.saveNotes(filteredNotes);

        emit(NotesLoaded(notes: filteredNotes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
      if (state is NotesLoaded) {
        emit(state);
      }
    }
  }

  // Helper method to create sample notes
  List<Note> _createSampleNotes() {
    return [
      Note(
        id: const Uuid().v4(),
        title: 'Submit Proposal',
        content: 'Review terms with team and send out draft to client by second half of the month.',
        category: 'Work',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Read',
        content: 'Read 10 pages atleast',
        category: 'Personal',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Quiz on tuesday',
        content: 'topics:\n1. dynamic programming\n2. amortized algorithms',
        category: 'Study',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Tapal',
        content: 'Email deck to be sent out by Friday',
        category: 'Work',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Run times',
        content: '12 min\n20 min\n22 min\n30 min\n33 min',
        category: 'Personal',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}