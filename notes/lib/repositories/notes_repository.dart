import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesRepository {
  static const String _notesKey = 'notes_data';

  // Save notes to SharedPreferences
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert notes to JSON format
    final notesJson = notes.map((note) => {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'createdAt': note.createdAt.toIso8601String(),
    }).toList();

    // Save as string
    await prefs.setString(_notesKey, jsonEncode(notesJson));
  }

  // Load notes from SharedPreferences
  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    // Get saved string
    final notesString = prefs.getString(_notesKey);

    if (notesString == null || notesString.isEmpty) {
      return []; // Return empty list if no data
    }

    try {
      // Decode JSON
      final notesJson = jsonDecode(notesString) as List;

      // Convert to List<Note>
      return notesJson.map((noteJson) => Note(
        id: noteJson['id'],
        title: noteJson['title'],
        content: noteJson['content'],
        category: noteJson['category'],
        createdAt: DateTime.parse(noteJson['createdAt']),
      )).toList();
    } catch (e) {
      print('Error loading notes: $e');
      return []; // Return empty list on error
    }
  }
}