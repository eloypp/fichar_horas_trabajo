import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20.0, 
          fontWeight: FontWeight.bold, 
        ),
      ),
      body: Center(
        child: Text(
          'Este es el panel de administración.',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}