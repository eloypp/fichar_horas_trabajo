import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'login.dart';
import 'home.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data() as Map<String, dynamic>?;
      final String? imageUrl = data?['profileImageUrl'] as String?;
      if (imageUrl != null) {
        print('URL de imagen recuperada de Firestore: $imageUrl');
        setState(() {
          _profileImageUrl = imageUrl;
        });
      } else {
        print('No se encontró la URL de imagen en Firestore.');
      }
    } catch (e) {
      print('Error al cargar la imagen desde Firestore: $e');
    }
  }
}

  Future<void> _changeDisplayName(BuildContext context) async {
    final TextEditingController _displayNameController = TextEditingController();
    final User? user = FirebaseAuth.instance.currentUser;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Nuevo Nombre Usuario',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(hintText: 'Ingrese nuevo nombre de usuario'),
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
              child: const Text('Actualizar'),
              onPressed: () async {
                if (_displayNameController.text.isNotEmpty) {
                  try {
                    // Actualizar el nombre de usuario en Firebase Authentication
                    await user?.updateDisplayName(_displayNameController.text);
                    await user?.reload();

                    // Actualizar el nombre de usuario en Firestore
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'displayName': _displayNameController.text});
                    }

                    setState(() {});
                    Navigator.of(context).pop();

                    // Refrescar la pantalla de inicio
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } catch (e) {
                    // Manejar errores si es necesario
                    print('Error al actualizar el nombre de usuario: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convertir XFile a bytes
      final Uint8List fileBytes = await pickedFile.readAsBytes();

      // Subir los bytes a Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images').child(user.uid);

      await storageRef.putData(fileBytes);
      final String downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'profileImageUrl': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nombre de usuario: ${user?.displayName ?? 'Usuario'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _changeDisplayName(context);
                    },
                    child: const Text('Cambiar Nombre Usuario'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email:',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'Email no disponible',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}