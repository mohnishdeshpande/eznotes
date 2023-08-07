import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utils/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final List<CloudNote> notes;
  final NoteCallBack onDelete;
  final NoteCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: [
        for (final note in notes)
          Card(
            color: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            key: ValueKey(note),
            child: ListTile(
              onTap: () {
                onTap(note);
              },
              title: Text(
                note.heading,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDelete(note);
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) newIndex--;
        final curTile = notes.removeAt(oldIndex);
        notes.insert(newIndex, curTile);
      },
    );
  }
}
