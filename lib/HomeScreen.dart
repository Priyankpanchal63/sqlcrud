import 'package:flutter/material.dart';
import 'package:sqlcrud/databse/db_hendler.dart';
import 'package:sqlcrud/model.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DbHelper? dbHelper;
  late Future<List<NotesModel>> noteList;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    loadData();
  }

  loadData() async {
    noteList = dbHelper!.getNotesList();
    setState(() {});
  }

  // Function to update the data
  void _updateNote(NotesModel note) async {
    _showFormDialog(note: note);
  }

  // Function to delete the note
  void _deleteNote(int id) async {
    await dbHelper!.delete(id);
    loadData(); // Refresh the list after deleting
  }

  // Function to show dialog for adding or updating notes
  void _showFormDialog({NotesModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final descriptionController =
        TextEditingController(text: note?.description ?? '');
    final ageController =
        TextEditingController(text: note?.age?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Update Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate and save the data
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  final newNote = NotesModel(
                    id: note?.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    age: int.tryParse(ageController.text),
                    email: 'priyank@gmail.com',
                  );
                  if (note == null) {
                    // Insert new note
                    dbHelper?.insert(newNote);
                  } else {
                    // Update existing note
                    dbHelper?.Update(newNote);
                  }
                  loadData(); // Refresh the list
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Notes Sql')),
      ),
      body: FutureBuilder<List<NotesModel>>(
        future: noteList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notes available.'));
          }

          // Data is available
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final note = snapshot.data![index];
              return InkWell(
                onTap: () => _updateNote(note), // Trigger update on tap
                child: Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete_forever),
                  ),
                  onDismissed: (DismissDirection direction) {
                    _deleteNote(note.id!); // Delete note if swiped
                  },
                  key: ValueKey<int>(note.id!),
                  child: Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      title: Text(note.title ?? 'No Title'),
                      subtitle: Text(note.description ?? 'No Description'),
                      trailing: Text(note.age?.toString() ?? 'N/A'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormDialog(); // Show dialog to add a new note
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
