import 'package:flutter/material.dart';

import '../../models/help_item.dart';

class HelpDialog extends StatelessWidget {
  final List<HelpItem> helpItems;

  const HelpDialog({
    Key? key,
    required this.helpItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int number = 1;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var item in helpItems) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${number++}. ${item.titleLocalKey}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(item.contentLocalKey),
              ),
            ],
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        ),
      ),
    );
  }
}
