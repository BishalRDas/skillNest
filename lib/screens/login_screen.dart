import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'user_home.dart';
import 'worker_home.dart';
import 'admin_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  AuthService auth = AuthService();

  Future<void> login() async {
    String role = await auth.login(email.text, password.text);

    if (!mounted) return;

    if (role == "User") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserHome()),
      );
    }

    if (role == "Worker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WorkerHome()),
      );
    }

    if (role == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4A90E2), Color(0xff6FB1FC)],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Card(
                elevation: 10,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(25),

                  child: Column(
                    children: [
                      Icon(
                        Icons.home_repair_service,
                        size: 70,
                        color: Colors.blue,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "SkillNest",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        "Skill Labour App",
                        style: TextStyle(color: Colors.grey),
                      ),

                      SizedBox(height: 30),

                      /// EMAIL
                      TextField(
                        controller: email,

                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),

                          hintText: "Email",

                          filled: true,

                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      /// PASSWORD
                      TextField(
                        controller: password,

                        obscureText: true,

                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),

                          hintText: "Password",

                          filled: true,

                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: login,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: Text("Login", style: TextStyle(fontSize: 18)),
                        ),
                      ),

                      SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterScreen()),
                          );
                        },

                        child: Text("Create New Account"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
