import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/timeTracker.dart';
import 'history.dart';
import 'profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final timeTracker = Provider.of<TimeTracker>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichar Horas Trabajo'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 10, 192, 192),
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de horas fichadas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (user != null)
                  Text(
                    '¡Bienvenid@, ${user.displayName ?? 'Usuario'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                if (timeTracker.startTime == null)
                  ElevatedButton(
                    onPressed: () {
                      timeTracker.startTracking();
                    },
                    child: const Text('Iniciar'),
                  )
                else if (timeTracker.endTime == null) ...[
                  Text('Duration: ${timeTracker.formattedDuration}'),
                  ElevatedButton(
                    onPressed: () {
                      timeTracker.stopTracking();
                    },
                    child: const Text('Finalizar Actividad'),
                  ),
                ]
                else ...[
                  Text('Start Time: ${timeTracker.startTime}'),
                  Text('End Time: ${timeTracker.endTime}'),
                  Text('Duración Total: ${timeTracker.formattedDuration}'),
                  ElevatedButton(
                    onPressed: () {
                      timeTracker.resetTracking();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}