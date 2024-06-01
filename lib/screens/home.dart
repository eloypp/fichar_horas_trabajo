
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/timeTracker.dart';
import 'history.dart';
import 'profile.dart';
import 'admin.dart';
import '../controllers/userController.dart';
import 'package:fichar_horas_trabajo/screens/tasks_list.dart';
import 'package:fichar_horas_trabajo/assets/widgets/geometricBackground.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;
  final UserController _userController = UserController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedDepartment;
  String? _selectedConcept;

  final List<String> _departments = [
    'Arte',
    'Diseño Narrativo',
    'Música',
    'Programación',
    'Investigación',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    User? user = _userController.getCurrentUser();
    if (user != null) {
      String? role = await _userController.getUserRole(user.uid);
      setState(() {
        userRole = role;
      });
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Baja':
        return Colors.green;
      case 'Media':
        return Colors.blue;
      case 'Alta':
        return Colors.orange;
      case 'Muy Alta':
        return Colors.deepOrange;
      case 'Urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showInfoDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Información'),
        content: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: 'Bienvenido a Fichar Tareas, tu aplicación para fichar y visualizar todas las tareas pendientes del proyecto. '
                    'Selecciona un departamento, la actividad que quieres realizar... ¡Y que empiece la acción! :D\n\n',
              ),
              TextSpan(
                text: 'Nota: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Si al finalizar una actividad quieres volverla a iniciar y la aplicación no te deja vuelve a seleccionar '
                    'nuevamente las opciones de los dos campos y se arreglará el problema. Gracias por tu atención.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final timeTracker = Provider.of<TimeTracker>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichar Horas Trabajo'),
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20.0, 
          fontWeight: FontWeight.bold, 
        ),
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
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Lista de Tareas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksPage()),
                );
              },
            ),
            if (userRole == 'admin')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                  );
                },
              ),
          ],
        ),
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            StreamBuilder<User?>(
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Departamento* :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                DropdownButtonFormField<String>(
                                  value: _selectedDepartment,
                                  hint: const Text('Selecciona un Departamento'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedDepartment = newValue;
                                    });
                                    timeTracker.setSelectedDepartment(newValue!);
                                  },
                                  validator: (value) =>
                                      value == null ? 'Campo obligatorio' : null,
                                  items: _departments
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  'Concepto* :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                    .collection('Tasks')
                                    .orderBy('prioridad', descending: true)
                                    .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return const Text('Error al cargar las tareas');
                                    }
                                    final tasks = snapshot.data!.docs;

                                    if (tasks.isEmpty) {
                                      return const Text('No hay tareas disponibles');
                                    }

                                    return DropdownButtonFormField<String>(
                                      value: _selectedConcept,
                                      hint: const Text('Selecciona un Concepto'),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedConcept = newValue;
                                        });
                                        timeTracker.setConcept(newValue!);
                                      },
                                      validator: (value) => value == null ? 'Campo obligatorio' : null,
                                      items: tasks.map<DropdownMenuItem<String>>((DocumentSnapshot document) {
                                        final taskData = document.data() as Map<String, dynamic>;
                                        final String taskName = taskData['tarea'];
                                        final String priority = taskData['prioridad'];
                                        final Color priorityColor = _getPriorityColor(priority);
                                        return DropdownMenuItem<String>(
                                          value: taskName,
                                          child: Text(
                                            taskName,
                                            style: TextStyle(color: priorityColor),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      timeTracker.startTracking();
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: const Text('Hay campos obligatorios sin rellenar'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Iniciar Actividad'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (timeTracker.endTime == null) ...[
                        Text('Duración: ${timeTracker.formattedDuration}'),
                        ElevatedButton(
                          onPressed: () {
                            timeTracker.stopTracking();
                          },
                          child: const Text('Finalizar Actividad'),
                        ),
                      ]
                      else ...[
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
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _showInfoDialog,
                child: const Icon(Icons.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
