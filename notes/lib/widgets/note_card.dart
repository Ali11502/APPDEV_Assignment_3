import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../models/note.dart';
import '../screens/note_form_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _getColorForCategory(note.category),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Bottom row with category and action icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category text (bottom left)
                Text(
                  note.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: _getCategoryTextColor(note.category),
                  ),
                ),

                // Action icons (bottom right)
                Row(
                  children: [
                    // Edit icon
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteFormScreen(noteToEdit: note),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Delete icon
                    InkWell(
                      onTap: () {
                        _showDeleteConfirmation(context, note);
                      },
                      child: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFFFFF9C4); // Yellow
      case 'personal':
        return const Color(0xFFA6DEFF); // Blue
      case 'study':
        return const Color(0xFFF8BBD0); // Pink
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getCategoryTextColor(String category) {
    // You can customize text color for each category if needed
    switch (category.toLowerCase()) {
      case 'work':
      case 'personal':
      case 'study':
        return Colors.black54; // Using a slightly darker text for better readability
      default:
        return Colors.black54;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<NotesBloc>().add(DeleteNote(id: note.id));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}