import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String content) {
  return showGenericDialog<void>(
    context: context,
    title: 'Error',
    content: content,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
