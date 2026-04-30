import 'dart:ui';
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

  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController skill = TextEditingController();
  TextEditingController experience = TextEditingController();
  TextEditingController adminCode = TextEditingController();

  String role = "User";

  AuthService auth = AuthService();

  Future<void> register() async {
    await auth.register(
      name.text,
      email.text,
      password.text,
      role,
      phone: phone.text,
      address: address.text,
      skill: skill.text,
      experience: experience.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 BACKGROUND (same style as your login UI)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0F172A), Color(0xff1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔵 LIGHT BLOBS
          Positioned(top: -80, right: -60, child: _circle(180)),
          Positioned(bottom: -100, left: -80, child: _circle(220)),

          /// 🧊 GLASS CARD
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// SAME FIELDS (UNCHANGED)
                        _inputField(name, Icons.person, "Full Name"),
                        const SizedBox(height: 12),

                        _inputField(email, Icons.email, "Email"),
                        const SizedBox(height: 12),

                        _inputField(
                          password,
                          Icons.lock,
                          "Password",
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),

                        _inputField(phone, Icons.phone, "Phone Number"),

                        const SizedBox(height: 20),

                        /// ROLE
                        Row(
                          children: [
                            Expanded(child: _roleCard("User", Icons.person)),
                            const SizedBox(width: 8),
                            Expanded(child: _roleCard("Worker", Icons.build)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _roleCard(
                                "Admin",
                                Icons.admin_panel_settings,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// DYNAMIC FIELDS
                        if (role == "User") ...[
                          _inputField(address, Icons.location_on, "Address"),
                        ],

                        if (role == "Worker") ...[
                          _inputField(skill, Icons.work, "Skill"),
                          const SizedBox(height: 12),
                          _inputField(
                            experience,
                            Icons.timer,
                            "Experience (years)",
                          ),
                        ],

                        if (role == "Admin") ...[
                          _inputField(adminCode, Icons.security, "Admin Code"),
                        ],

                        const SizedBox(height: 25),

                        /// BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xff1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Already have account? Login",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔵 BACKGROUND CIRCLE
  Widget _circle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }

  /// ❌ NOT CHANGED (as you requested)
  Widget _inputField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleCard(String text, IconData icon) {
    bool selected = role == text;

    return GestureDetector(
      onTap: () => setState(() => role = text),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xff1D4ED8) : Colors.white,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: selected ? const Color(0xff1D4ED8) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
