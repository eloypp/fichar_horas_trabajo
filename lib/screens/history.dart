import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../providers/timeTracker.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de horas fichadas'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('trackingHistory').orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los datos'));
                }

                final data = snapshot.data!.docs;

                return Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(100.0),
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                    4: FixedColumnWidth(100.0),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 5, 163, 163),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Fecha',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Hora Inicio',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Hora Fin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Tiempo Total',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...data.map((doc) {
                      final record = doc.data() as Map<String, dynamic>;
                      final date = (record['date'] as Timestamp).toDate();
                      final startTime = (record['startTime'] as Timestamp).toDate();
                      final endTime = (record['endTime'] as Timestamp).toDate();
                      final duration = Duration(seconds: record['duration'] as int);
                      final user = record['user'] as String;

                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatDate(date)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatTime(startTime)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatTime(endTime)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              TimeTracker.formatDuration(duration),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(user),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
