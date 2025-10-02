
import 'package:flutter/material.dart';

class GameMenuSheet extends StatelessWidget {
  const GameMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Implement settings navigation or functionality
              Navigator.pop(context);
            },
          ),
          // Add other menu items here in the future
        ],
      ),
    );
  }
}
