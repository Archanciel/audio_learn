import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../viewmodels/theme_provider_vm.dart';

class CommentAddDialogWidget extends StatefulWidget {
  const CommentAddDialogWidget({
    super.key,
  });

  @override
  State<CommentAddDialogWidget> createState() => _CommentAddDialogWidgetState();
}

class _CommentAddDialogWidgetState extends State<CommentAddDialogWidget>
    with ScreenMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final FocusNode _dialogFocusNode = FocusNode();
  final FocusNode _focusNodePlaylistRootPath = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Required so that clicking on Enter closes the dialog
      FocusScope.of(context).requestFocus(
        _dialogFocusNode,
      );
    });
  }

  @override
  void dispose() {
    _dialogFocusNode.dispose();
    _focusNodePlaylistRootPath.dispose();
    titleController.dispose();
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodePlaylistRootPath,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _dialogFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save' TextButton
            // onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.commentDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextField for Title
              SizedBox(
                height: kDialogTextFieldHeight,
                child: TextField(
                  controller: titleController,
                  decoration: getDialogTextFieldInputDecoration(
                    hintText: AppLocalizations.of(context)!.commentTitle,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Multiline TextField for Comments
              TextField(
                controller: commentController,
                minLines: 2,
                maxLines: 3,
                decoration: getDialogTextFieldInputDecoration(
                  hintText: AppLocalizations.of(context)!.commentText,
                ),
              ),
              const SizedBox(height: 30),
              // Non-editable Text for Audio File Details
              // Audio Playback Controls
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      '231127-001208-Jancovici - débat avec Bernard Friot - Aix en Provence - 16_11_2023\n23-11-23.mp3',
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.fast_rewind),
                            onPressed: null,
                          ),
                          Text('2:20:45'),
                          IconButton(
                            icon: Icon(Icons.fast_forward),
                            onPressed: null,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: null,
                        padding: EdgeInsets.all(0), // Remove extra padding
                        constraints:
                            BoxConstraints(), // Ensure the button takes minimal space
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Logique de confirmation (sauvegarder les commentaires, etc.)
              print('Titre: ${titleController.text}');
              print('Commentaire: ${commentController.text}');
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.add,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );
  }
}
