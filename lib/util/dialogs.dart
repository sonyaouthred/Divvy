import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
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
  String message = 'Are you sure?',
}) async {
  final res = await showCupertinoDialog<bool>(
    context: context,
    builder:
        (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
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

/// Display a box the user uses to select a color for their profile.
Future<ProfileColor> openColorDialog(
  BuildContext context,
  ProfileColor initColor,
  double spacing,
) async {
  ProfileColor chosenColor = initColor;
  await showDialog(
    context: context,
    builder:
        (BuildContext context) => Dialog(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult:
                (didPop, result) => {if (!didPop) Navigator.pop(context)},
            child: Container(
              decoration: DivvyTheme.standardBox,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: DropdownButtonFormField(
                value: chosenColor,
                borderRadius: BorderRadius.circular(15),
                elevation: 3,
                decoration: const InputDecoration(border: InputBorder.none),
                dropdownColor: DivvyTheme.background,
                items:
                    ProfileColor.values
                        .map<DropdownMenuItem<ProfileColor>>(
                          (ProfileColor color) =>
                              DropdownMenuItem<ProfileColor>(
                                value: color,
                                child: Row(
                                  children: [
                                    Icon(Icons.circle, color: color.color),
                                    SizedBox(width: spacing / 2),
                                    Text(
                                      color.name,
                                      style: DivvyTheme.bodyBlack,
                                    ),
                                  ],
                                ),
                              ),
                        )
                        .toList(),
                onChanged: (ProfileColor? value) {
                  if (value != null) {
                    // This is called when the user selects an item.
                    chosenColor = value;
                  }
                },
              ),
            ),
          ),
        ),
  );
  return chosenColor;
}
