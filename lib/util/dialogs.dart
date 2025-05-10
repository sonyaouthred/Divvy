import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a generic error dialog.
/// Displays the inputted title and error message.
/// Only action allowed is 'Ok'.
Future<void> showErrorMessage(
  BuildContext context,
  String title,
  String error,
) async {
  await showCupertinoDialog(
    context: context,
    builder:
        (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(error),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
  );
}

/// Opens a dialog allowing user to enter a String input.
/// Displays the inputted title and prompt.
/// The initText is the prompt within the text field.
///
/// Returns the String the user inputted.
Future<String?> openInputDialog(
  BuildContext context, {
  required String title,
  String? prompt,
  String? initText,
  bool hideText = false,
}) async {
  final controller = TextEditingController(text: initText ?? '');
  final res = await showCupertinoDialog<String>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            SizedBox(height: 10),
            CupertinoTextField(
              placeholder: prompt,
              controller: controller,
              obscureText: hideText,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    },
  );
  return res;
}

/// Confirm user wants to delete something.
Future<bool?> confirmDeleteDialog(
  BuildContext context,
  String title, {
  String action = 'Delete',
}) async {
  final res = await showCupertinoDialog<bool>(
    context: context,
    builder:
        (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text('Are you sure?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(action),
            ),
          ],
        ),
  );
  return res;
}
