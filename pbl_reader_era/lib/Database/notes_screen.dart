import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _loadNotesWithSampleData();
  }

  Future<List<Note>> _loadNotesWithSampleData() async {
    var notes = await DatabaseHelper.instance.getNotes();

    if (notes.isEmpty) {
      List<Note> sampleNotes = List.generate(5, (index) {
        return Note(
          title: 'DB Note ${index + 1}',
          content: 'This is the content of sample note number ${index + 1}.',
          createdAt: DateTime.now().subtract(Duration(days: index)),
        );
      });

      for (var note in sampleNotes) {
        await DatabaseHelper.instance.insertNote(note);
      }

      notes = await DatabaseHelper.instance.getNotes();
    }
    return notes;
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _notesFuture = _loadNotesWithSampleData();
    });
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    final isNew = note == null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newContent = contentController.text.trim();

              if (newTitle.isEmpty || newContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter title and content')),
                );
                return;
              }

              if (isNew) {
                await DatabaseHelper.instance.insertNote(
                  Note(
                    title: newTitle,
                    content: newContent,
                    createdAt: DateTime.now(),
                  ),
                );
              } else {
                await DatabaseHelper.instance.updateNote(
                  Note(
                    id: note!.id,
                    title: newTitle,
                    content: newContent,
                    createdAt: note.createdAt,
                  ),
                );
              }

              Navigator.of(context).pop();
              await _refreshNotes();
            },
            child: Text(isNew ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteNote(note.id!);
      await _refreshNotes();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNoteDialog(),
            tooltip: 'Add Note',
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }

          final notes = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshNotes,
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 140,  // increased width to avoid overflow
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _formatDate(note.createdAt),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit Note',
                            onPressed: () => _showNoteDialog(note: note),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Note',
                            onPressed: () => _deleteNote(note),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
