import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:package_info/package_info.dart';

import '../model.dart';
import '../shared-pref-helper.dart';

const BUILD_NUMBER_TAPS_REQUIRED_TO_ENABLE_DEVELOPER_MODE = 10;

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Settings? settings;
  Timer? _developerModeTapCoolOffTimer;
  int _buildNumberTaps = 0;

  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      setState(() {
        settings = user.settings;
      });
    });
  }

  Widget _getAppVersion() => FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (ctx, snap) {
        switch (snap.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
          case ConnectionState.none:
            return Text("loading...");
          case ConnectionState.done:
            return Text("${snap.data?.version}+${snap.data?.buildNumber}");
          default:
            return Text("That's classified");
        }
      });

  @override
  Widget build(BuildContext context) {
    List<SettingsSection> settingsSections = [
      SettingsSection(
        // Set of similar settings items
        title: 'Misc',
        tiles: [
          SettingsTile(
              // Single Setting item
              title: 'Reset Progress',
              subtitle: 'That progress was no good anyway...',
              leading: Icon(Icons.replay),
              onPressed: (_) {
                clearSharedPrefs();
              }),
          SettingsTile(
              title: 'Build Version',
              leading: Icon(Icons.info_outline),
              trailing: _getAppVersion(),
              onPressed: (_) {
                if (_developerModeTapCoolOffTimer != null) {
                  _developerModeTapCoolOffTimer!.cancel();
                }
                _buildNumberTaps += 1;
                if (_buildNumberTaps >
                        BUILD_NUMBER_TAPS_REQUIRED_TO_ENABLE_DEVELOPER_MODE &&
                    !settings!.developerMode) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("You are now a developer!"),
                  ));
                  getUser().then((user) {
                    setState(() {
                      settings = Settings(developerMode: true);
                      setUser(User(settings: settings!));
                    });
                  });
                }
                _developerModeTapCoolOffTimer = Timer(Duration(seconds: 1), () {
                  _buildNumberTaps = 0;
                });
              }),
        ],
      ),
    ];
    if (settings != null && settings!.developerMode) {
      settingsSections.add(SettingsSection(
        title: "Developer",
        tiles: [
          SettingsTile(
              title: "Leave Developer Mode",
              leading: Icon(Icons.developer_mode),
              onPressed: (_) {
                getUser().then((user) {
                  setState(() {
                    settings = Settings(developerMode: false);
                    setUser(User(settings: settings!));
                  });
                });
              })
        ],
      ));
    }
    return Scaffold(
      body: SettingsList(
        // Whole setting Page
        sections: settingsSections,
      ),
    );
  }
}
