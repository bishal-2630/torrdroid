import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Download Location'),
            subtitle: Text('/storage/emulated/0/Download/TorrDroid'),
            leading: Icon(Icons.folder),
          ),
          SwitchListTile(
            title: const Text('Wi-Fi Only'),
            subtitle: const Text('Download only when connected to Wi-Fi'),
            value: true,
            onChanged: (val) {},
            secondary: const Icon(Icons.wifi),
          ),
          const ListTile(
            title: Text('Max Connections'),
            subtitle: Text('200'),
            leading: Icon(Icons.speed),
          ),
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Dark Mode'),
            leading: Icon(Icons.palette),
          ),
          const Divider(),
          const ListTile(
            title: Text('About TorrDroid Clone'),
            subtitle: Text('Version 1.0.0'),
            leading: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
