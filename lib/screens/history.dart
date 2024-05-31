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
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20.0, 
          fontWeight: FontWeight.bold, 
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 115, 250, 250), Color.fromARGB(255, 2, 90, 90)],
              ),
            ),
          ),
          // Contenido principal
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('trackingHistory')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar los datos'));
                    }

                    final data = snapshot.data!.docs;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FixedColumnWidth(100.0),
                          1: FixedColumnWidth(100.0),
                          2: FixedColumnWidth(100.0),
                          3: FixedColumnWidth(100.0),
                          4: FixedColumnWidth(100.0),
                          5: FixedColumnWidth(150.0),
                          6: FixedColumnWidth(230.0),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 4, 136, 136),
                            ),
                            children: const [
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Fecha',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Hora Inicio',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Hora Fin',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Tiempo Total',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Usuario',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Departamento',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Concepto',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
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
                            final department = record['department'] as String;
                            final concept = record['concept'] as String;

                            return TableRow(
                              decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                              children: [
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(TimeTracker.formatDate(date)),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(TimeTracker.formatTime(startTime)),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(TimeTracker.formatTime(endTime)),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        TimeTracker.formatDuration(duration),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(user),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(department),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(concept),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}