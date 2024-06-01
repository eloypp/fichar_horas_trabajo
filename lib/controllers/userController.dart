import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String email, String password, String displayName) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();

      // Guardar la información del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'user',
      });
    }
  }

  Future<void> createUserInFirestoreIfNotExists(User user, String displayName) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      // Guardar la información del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': displayName,
        'role': 'user',
      });
    }
  }

  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'];
    }
    return null;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateDisplayName(String newDisplayName) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.updateDisplayName(newDisplayName);
      await user.reload();

      // Actualizar el nombre de usuario en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newDisplayName,
      });
    }
  }
}