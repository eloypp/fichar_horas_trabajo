import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timeTracker.dart';
import '../vistas/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimeTracker(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fichar Horas Trabajo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
