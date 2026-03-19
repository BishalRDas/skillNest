import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ===============================
  /// REGISTER
  /// ===============================
  Future<String> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = user.user!.uid;

      /// Save user data
      await firestore.collection("users").doc(uid).set({
        "name": name,
        "email": email.trim(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// If Worker → create worker profile
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

      return "Success";
    } on FirebaseAuthException catch (e) {
      print("Register Error: ${e.code}");

      if (e.code == 'email-already-in-use') {
        return "Email already in use";
      } else if (e.code == 'weak-password') {
        return "Password too weak";
      } else if (e.code == 'invalid-email') {
        return "Invalid email";
      } else {
        return "Registration failed";
      }
    } catch (e) {
      print("General Register Error: $e");
      return "Something went wrong";
    }
  }

  /// ===============================
  /// LOGIN
  /// ===============================
  Future<String> login(String email, String password) async {
    try {
      UserCredential user = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = user.user!.uid;

      final doc = await firestore.collection("users").doc(uid).get();

      if (!doc.exists) {
        return "User data not found";
      }

      return doc["role"];
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.code}");

      if (e.code == 'user-not-found') {
        return "No user found";
      } else if (e.code == 'wrong-password') {
        return "Wrong password";
      } else if (e.code == 'invalid-email') {
        return "Invalid email";
      } else {
        return "Login failed";
      }
    } catch (e) {
      print("General Login Error: $e");
      return "Something went wrong";
    }
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  Future<void> logout() async {
    await auth.signOut();
  }
}
