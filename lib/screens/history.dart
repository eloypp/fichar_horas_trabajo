import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/timeTracker.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timeTracker = Provider.of<TimeTracker>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de horas fichadas'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(100.0),
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Fecha',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Hora Inicio',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Hora Fin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Tiempo Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...timeTracker.records.map((record) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatDate(record.date)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatTime(record.startTime)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TimeTracker.formatTime(record.endTime)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text
                            (TimeTracker.formatDuration(record.duration),
                             style: const TextStyle(fontWeight: FontWeight.bold),
                             ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
