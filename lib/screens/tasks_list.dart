import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/userController.dart';


class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedDepartment = 'Todos';
  String _selectedPriority = 'Todos';
  String _selectedSortOption = 'Prioridad';
  
  final UserController _userController = UserController();

  final List<String> departments = [
    'Todos',
    'Arte',
    'Diseño Narrativo',
    'Música',
    'Programación',
    'Investigación',
    'Otros'
  ];

  final List<String> priorities = [
    'Todos',
    'Baja',
    'Media',
    'Alta',
    'Muy Alta',
    'Urgente'
  ];

  final List<String> sortOptions = [
    'Prioridad',
    'Departamento',
    'Fecha de Creación'
  ];

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

  List<DocumentSnapshot> _sortTasks(List<DocumentSnapshot> tasks) {
    switch (_selectedSortOption) {
      case 'Prioridad':
        tasks.sort((a, b) {
          final priorityOrder = {'Urgente': 0, 'Muy Alta': 1, 'Alta': 2, 'Media': 3, 'Baja': 4};
          return priorityOrder[a['prioridad']]!.compareTo(priorityOrder[b['prioridad']]!);
        });
        break;
      case 'Departamento':
        tasks.sort((a, b) => a['departamento'].compareTo(b['departamento']));
        break;
      case 'Fecha de Creación':
        tasks.sort((a, b) => (b['fechaCreacion'] as Timestamp).compareTo(a['fechaCreacion'] as Timestamp));
        break;
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas Pendientes'),
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20.0, 
          fontWeight: FontWeight.bold, 
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showTaskDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 37, 56, 56),
              Color.fromARGB(255, 82, 167, 167),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      items: departments.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(
                            department,
                            style: TextStyle(
                              color: _selectedDepartment == department ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDepartment = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Departamento',
                        labelStyle: TextStyle(color: Colors.white), // Color del texto del label
                        border: OutlineInputBorder( // Personalización del borde del campo
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      items: priorities.map((String priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: _selectedPriority == priority ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Prioridad',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSortOption,
                      items: sortOptions.map((String sortOption) {
                        return DropdownMenuItem<String>(
                          value: sortOption,
                          child: Text(
                            sortOption,
                            style: TextStyle(
                              color: _selectedSortOption == sortOption ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSortOption = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Tasks').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar las tareas'));
                  }

                  List<DocumentSnapshot<Object?>> tasks = snapshot.data!.docs.where((task) {
                    final taskDepartment = task['departamento'];
                    final taskPriority = task['prioridad'];

                    final departmentMatch = _selectedDepartment == 'Todos' || _selectedDepartment == taskDepartment;
                    final priorityMatch = _selectedPriority == 'Todos' || _selectedPriority == taskPriority;

                    return departmentMatch && priorityMatch;
                  }).toList();

                  tasks = _sortTasks(tasks);

                  return ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final textColor = _getPriorityColor(task['prioridad']);
                      return ListTile(
                        title: Text(
                          task['tarea'],
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Departamento: ${task['departamento']}',
                              style: TextStyle(color: textColor),
                            ),
                            Text(
                              'Prioridad: ${task['prioridad']}',
                              style: TextStyle(color: textColor),
                            ),
                            Text(
                              'Porcentaje: ${task['porcentaje']}%',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showTaskDialog(context, task: task);
                              },
                            ),
                            IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? role = await _userController.getUserRole(user.uid);
      if (role == 'admin') {
        FirebaseFirestore.instance.collection('Tasks').doc(task.id).delete();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Permiso denegado'),
              content: const Text('No tienes permiso para borrar esta tarea.'),
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
    }
  },
),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {DocumentSnapshot? task}) {
    final TextEditingController tareaController = TextEditingController(text: task?['tarea'] ?? '');
    final TextEditingController porcentajeController = TextEditingController(text: task?['porcentaje']?.toString() ?? '0');
    String prioridad = task?['prioridad'] ?? 'Baja';
    String departamento = task?['departamento'] ?? 'Arte';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task == null ? 'Añadir Tarea' : 'Modificar Tarea'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: tareaController,
                  decoration: const InputDecoration(labelText: 'Tarea'),
                ),
                DropdownButtonFormField<String>(
                  value: prioridad,
                  items: priorities.where((label) => label != 'Todos').map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      prioridad = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                ),
                TextField(
                  controller: porcentajeController,
                  decoration: const InputDecoration(labelText: 'Porcentaje'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: departamento,
                  items: departments.sublist(1).map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      departamento = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Departamento'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                final String tarea = tareaController.text.trim();
                if (tarea.isEmpty) {
                  // Muestra un mensaje de error si el nombre de la tarea está vacío
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text('El nombre de la tarea no puede estar vacío'),
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
                  return;
                }

                final porcentaje = int.parse(porcentajeController.text);
                
                // Verificar si ya existe una tarea con el mismo nombre
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('Tasks')
                    .where('tarea', isEqualTo: tarea)
                    .get();

                final List<DocumentSnapshot> existingTasks = querySnapshot.docs;

                // Si estamos añadiendo una nueva tarea, la lista no debe contener elementos.
                // Si estamos editando una tarea, la lista debe contener solo la tarea que estamos editando.
                if (existingTasks.isNotEmpty && (task == null || (existingTasks.length > 1 || existingTasks.first.id != task.id))) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text('Ya existe una tarea con este nombre'),
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
                  return;
                }

                if (task == null) {
                  // Añadir nueva tarea
                  await FirebaseFirestore.instance.collection('Tasks').add({
                    'tarea': tarea,
                    'prioridad': prioridad,
                    'porcentaje': porcentaje,
                    'departamento': departamento,
                    'fechaCreacion': FieldValue.serverTimestamp(),
                  });
                } else {
                  // Modificar tarea existente
                  await FirebaseFirestore.instance.collection('Tasks').doc(task.id).update({
                    'tarea': tarea,
                    'prioridad': prioridad,
                    'porcentaje': porcentaje,
                    'departamento': departamento,
                  });
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}