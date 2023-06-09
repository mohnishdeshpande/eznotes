import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    final authService = AuthService.firebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        backgroundColor: Colors.blue,
        // define the 3 dot menu
        actions: [
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
                        'loginRoute',
                        (_) => false,
                      );
                    }
                  }
              }
            },
          )
        ],
      ),
      body: const Text('Hello'),
    );
  }
}

// method for log out dialog box
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
