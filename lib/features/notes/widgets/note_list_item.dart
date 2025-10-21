import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense_tracker/models/note_model.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  const NoteListItem({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          note.title, // Use the title field
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          note.content, // Use the content field
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(DateFormat.yMMMd().format(note.createdAt)),
      ),
    );
  }
}

