import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../widgets/empty_notes.dart';
import '../widgets/note_card.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentFilter = 'All';
  final List<String> _filterOptions = ['All', 'Work', 'Personal', 'Study'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocConsumer<NotesBloc, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is NotesLoaded) {
              final notes = state.notes;
              final filteredNotes = _currentFilter == 'All'
                  ? notes
                  : notes.where((note) => note.category == _currentFilter).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NoteIt',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButton<String>(
                            value: _currentFilter,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            items: _filterOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontWeight: FontWeight.normal),),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _currentFilter = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredNotes.isEmpty
                        ? const EmptyNotes()
                        : GridView.builder(
                      padding: const EdgeInsets.all(12.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context){
                                  return Wrap(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            // mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            // mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    note.title,
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        color: _getColorForCategory(note.category),
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                    child: Center(child: Text(note.category)),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 10,),
                                              Text(
                                                note.content,
                                                style: TextStyle(fontWeight: FontWeight.w300),)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Transform.rotate(
                              angle: -3.142/24,
                              child: NoteCard(note: note),),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text('Something went wrong!'),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteFormScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

Color _getColorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'work':
      return const Color(0xFFF9E89F); // Yellow
    case 'personal':
      return const Color(0xFFA6DEFF); // Blue
    case 'study':
      return const Color(0xFFF8BBD0); // Pink
    default:
      return Colors.grey[200]!;
  }
}