import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// REGISTER

  Future register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    UserCredential user = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = user.user!.uid;

    // Save in users collection
    await firestore.collection("users").doc(uid).set({
      "name": name,
      "email": email.trim(),
      "role": role,
    });

    // ✅ If role is Worker → also create workers document
    if (role == "Worker") {
      await firestore.collection("workers").doc(uid).set({
        "name": name,
        "email": email.trim(),
        "phone": "",
        "skill": "",
        "experience": "",
        "isAvailable": true,
        "isApproved": false,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  /// LOGIN

  Future<String> login(String email, String password) async {
    UserCredential user = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    var doc = await firestore.collection("users").doc(user.user!.uid).get();

    return doc["role"];
  }

  /// LOGOUT (IMPORTANT)

  Future logout() async {
    await auth.signOut();
  }
}
