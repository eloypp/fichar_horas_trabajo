import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timeTracker.dart';
import 'history.dart';

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
                color: Colors.blue,
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
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (timeTracker.startTime == null)
              ElevatedButton(
                onPressed: () {
                  timeTracker.startTracking();
                },
                child: const Text('Start Tracking'),
              )
            else if (timeTracker.endTime == null) ...[
              Text('Duration: ${timeTracker.formattedDuration}'),
              ElevatedButton(
                onPressed: () {
                  timeTracker.stopTracking();
                },
                child: const Text('Stop Tracking'),
              ),
            ]
            else ...[
              Text('Start Time: ${timeTracker.startTime}'),
              Text('End Time: ${timeTracker.endTime}'),
              Text('Total Duration: ${timeTracker.formattedDuration}'),
              ElevatedButton(
                onPressed: () {
                  timeTracker.resetTracking();
                },
                child: const Text('Reset'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
