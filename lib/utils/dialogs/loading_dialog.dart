import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  // so that the function can be called and acted upon by others
  return () => Navigator.of(context).pop();
}
