import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

import '../../constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  // '!' asks Dart to force grab the string
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // init notes service and open DB
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // __clearNotes(authService);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        // define the 3 dot menu
        actions: [
          IconButton(
            onPressed: () {
              // go to new note view
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout && context.mounted) {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }
            },
            icon: const Icon(Icons.logout),
          ),
          // action button, that takes MenuAction as input
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // follow-through case - two case having the same logic
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final notes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: notes,
                  onDelete: (note) async {
                    await _notesService.deleteNote(docId: note.docId);
                  },
                  onTap: (note) {
                    /*passing note as argument so that
                              createOrUpdate routine understands its an
                              update operation*/
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
