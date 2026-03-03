import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/user_home.dart';
import 'screens/worker_home.dart';
import 'screens/admin_home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthCheck());
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginScreen();
    }

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var role = snapshot.data!["role"];

        if (role == "User") {
          return UserHome();
        }

        if (role == "Worker") {
          return WorkerHome();
        }

        return AdminHome();
      },
    );
  }
}
