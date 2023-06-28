import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

import '../../constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  // '!' asks Dart to force grab the string
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    // init notes service and open DB
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.firebase();
    // __clearNotes(authService);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          backgroundColor: Colors.blue,
          // define the 3 dot menu
          actions: [
            IconButton(
              onPressed: () {
                // go to new note view
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            // action button, that takes MenuAction as input
            PopupMenuButton<MenuAction>(
              // responsible for displaying the all actions to the user
              itemBuilder: (context) {
                // list of all coded actions
                return const [
                  PopupMenuItem<MenuAction>(
                    // parameter value
                    value: MenuAction.logout,
                    // user displayed text
                    child: Text('Log out'),
                  )
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await authService.logOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (_) => false,
                        );
                      }
                    }
                }
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // follow-through case - two case having the same logic
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final notes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: notes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(noteId: note.id);
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
