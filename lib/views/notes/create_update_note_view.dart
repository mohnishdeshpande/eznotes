import 'package:flutter/material.dart';
import 'package:mynotes/utils/generics/get_argument.dart';

import '../../services/auth/auth_service.dart';
import '../../services/crud/notes_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  // required memebers for the state
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  // new note routine
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();

    // widgetNote not null means, note already exists and we have to update
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    // otherwise continue the routine for creating new note

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // force unwrap the current user, it is guaranteed to have user at this view
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    // return the created note from notes service
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  // discard note if user exits and note is empty
  void _deleteNoteIfEmpty() async {
    // creating a temp 'note' since '_note' is nullable.
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(noteId: note.id);
    }
  }

  // saving note data if not empty
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(noteId: note.id, text: text);
    }
  }

  void _textEditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(noteId: note.id, text: text);
  }

  void _setupTextEditingController() {
    _textController.removeListener(_textEditingControllerListener);
    _textController.addListener(_textEditingControllerListener);
  }

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextEditingController();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
