import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utils/generics/get_argument.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utils/dialogs/cannot_share_empty_note_dialog.dart';

import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  // required memebers for the state
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _headingController;

  // new note routine
  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    // widgetNote not null means, note already exists and we have to update
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _headingController.text = widgetNote.heading;
      return widgetNote;
    }

    // otherwise continue the routine for creating new note

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // force unwrap the current user, it is guaranteed to have user at this view
    final userId = AuthService.firebase().currentUser!.id;
    final newNote = await _notesService.createNewNote(userId: userId);
    _note = newNote;
    return newNote;
  }

  // discard note if user exits and note is empty
  void _deleteNoteIfEmpty() async {
    // creating a temp 'note' since '_note' is nullable.
    final note = _note;
    if (_textController.text.isEmpty && _headingController.text.isEmpty && note != null) {
      await _notesService.deleteNote(docId: note.docId);
    }
  }

  // saving note data if not empty
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final heading = _headingController.text;
    final text = _textController.text;
    if ((text.isNotEmpty || heading.isNotEmpty) && note != null) {
      await _notesService.updateNote(docId: note.docId, heading: heading, text: text);
    }
  }

  void _textEditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    final heading = _headingController.text;
    await _notesService.updateNote(
      docId: note.docId,
      heading: heading,
      text: text,
    );
  }

  void _setupTextEditingController() {
    _textController.removeListener(_textEditingControllerListener);
    _textController.addListener(_textEditingControllerListener);
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _headingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    _headingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              _saveNoteIfNotEmpty();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextEditingController();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _headingController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Title',
                          filled: true,
                          fillColor: Colors.blue[100],
                          // focusedBorder: MyTheme.buildBorder(Colors.grey[600]!, isNote: true),
                          // enabledBorder: MyTheme.buildBorder(Colors.blue[200]!, isNote: true),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write your note here...',
                          filled: true,
                          fillColor: Colors.blue[100],
                          // focusedBorder: MyTheme.buildBorder(Colors.grey[600]!, isNote: true),
                          // enabledBorder: MyTheme.buildBorder(Colors.blue[200]!, isNote: true),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
