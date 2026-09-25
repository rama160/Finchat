import 'package:flutter/material.dart';

import '../../main.dart';

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
            onPressed: SessionScope.of(context).logout,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text('Halo ${session?.email ?? ''}. Foundation Phase 2 siap.'),
      ),
    );
  }
}
