import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  String role = "User";

  AuthService auth = AuthService();

  Future<void> register() async {
    await auth.register(name.text, email.text, password.text, role);

    if (!mounted) return;

    Navigator.pop(context);
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),

                elevation: 10,

                child: Padding(
                  padding: const EdgeInsets.all(25),

                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Register to SkillNest",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 30),

                      /// NAME FIELD
                      TextField(
                        controller: name,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),

                          hintText: "Full Name",

                          filled: true,

                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// EMAIL
                      TextField(
                        controller: email,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),

                          hintText: "Email",

                          filled: true,

                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextField(
                        controller: password,

                        obscureText: true,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),

                          hintText: "Password",

                          filled: true,

                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// ROLE SELECTOR
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Role",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          roleCard("User", Icons.person),

                          roleCard("Worker", Icons.build),

                          roleCard("Admin", Icons.admin_panel_settings),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,

                        height: 50,

                        child: ElevatedButton(
                          onPressed: register,

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),

                            backgroundColor: Colors.blue,
                          ),

                          child: const Text(
                            "Register",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: const Text("Already have account? Login"),
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

  /// ROLE CARD UI

  Widget roleCard(String text, IconData icon) {
    bool selected = role == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          role = text;
        });
      },

      child: Container(
        width: 80,
        height: 80,

        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey.shade200,

          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black),

            const SizedBox(height: 5),

            Text(
              text,
              style: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
