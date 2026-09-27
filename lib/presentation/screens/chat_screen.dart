import 'package:flutter/material.dart';

import '../../main.dart';
import 'report_screen.dart';
<<<<<<< HEAD
import 'settings_screen.dart';
=======
>>>>>>> origin/main

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context).session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinChat'),
        actions: [
          IconButton(
            onPressed: session == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(userId: session.userId),
                      ),
                    ),
            tooltip: 'Laporan',
            icon: const Icon(Icons.analytics_outlined),
          ),
          IconButton(
<<<<<<< HEAD
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
=======
>>>>>>> origin/main
            onPressed: SessionScope.of(context).logout,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
<<<<<<< HEAD
        child: Text('Halo ${session?.email ?? ''}. Offline-first personal finance assistant.'),
=======
        child: Text('Halo ${session?.email ?? ''}. Foundation Phase 2 siap.'),
>>>>>>> origin/main
      ),
    );
  }
}
