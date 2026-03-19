import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/user_home.dart';
import 'screens/worker_home.dart';
import 'screens/admin_home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

/// 🎨 COLOR PALETTE
class AppColors {
  static const primary = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF2563EB);

  static const background = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  static const buttonText = Color(0xFFFFFFFF);

  static const border = Color(0xFFE5E7EB);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🎨 GLOBAL THEME
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,

        primaryColor: AppColors.primary,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        cardColor: AppColors.card,

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),

        /// Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        /// Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),

        /// Divider
        dividerColor: AppColors.border,
      ),

      home: AuthCheck(),
    );
  }
}

/// ================= AUTH CHECK =================

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    /// 🔐 Not logged in
    if (user == null) {
      return const LoginScreen();
    }

    /// 🔄 Check role from Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        /// ⏳ Loading
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        /// ❌ Safety check
        if (data == null || !data.containsKey("role")) {
          return const Scaffold(
            body: Center(child: Text("User role not found")),
          );
        }

        final role = data["role"];

        /// 🎯 Navigate based on role
        if (role == "User") {
          return const UserHome();
        }

        if (role == "Worker") {
          return const WorkerHome();
        }

        return const AdminHome();
      },
    );
  }
}
