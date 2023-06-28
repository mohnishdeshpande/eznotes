import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout?',
    optionBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
    // return value if chose, else return default false value
  ).then((value) => value ?? false);
}
