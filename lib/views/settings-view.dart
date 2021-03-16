import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      // Whole setting Page
      sections: [
        SettingsSection(
          // Set of similar settings items
          title: 'Progress',
          tiles: [
            SettingsTile(
              // Single Setting item
              title: 'Reset Progress',
              subtitle: 'That progress was no good anyway...',
              leading: Icon(Icons.replay),
            ),
          ],
        ),
      ],
    );
  }
}
