import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/otp_service.dart';
import 'login_screen.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int currentIndex = 0;

  final pages = [
    WorkerAccountTab(),
    const RequestTab(),
    const WorkerHistoryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1D4ED8), Color(0xff2563EB)],
              ),
            ),
          ),
          SafeArea(child: pages[currentIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(blurRadius: 25, color: Colors.black.withOpacity(0.08)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.person, 0),
            _navItem(Icons.work, 1),
            _navItem(Icons.history, 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff1D4ED8) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: selected ? Colors.white : Colors.grey),
      ),
    );
  }
}

/// ================= ACCOUNT =================

class WorkerAccountTab extends StatelessWidget {
  WorkerAccountTab({super.key});

  final auth = AuthService();
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("workers").doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        bool isApproved = data['isApproved'] ?? false;
        bool isAvailable = data['isAvailable'] ?? false;
        bool isPhoneVerified = data['isPhoneVerified'] ?? false;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          children: [
            /// PROFILE
            /// PROFILE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xff1D4ED8)),
                  ),
                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        data['email'] ?? "",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        data['phone'] ?? "",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "Skill: ${data['skill'] ?? ""}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "Exp: ${data['experience'] ?? ""}",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 5),

                      /// APPROVAL STATUS
                      Text(
                        isApproved ? "Approved" : "Pending Approval",
                        style: TextStyle(
                          color: isApproved
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// PHONE VERIFIED
                      Row(
                        children: [
                          const Text(
                            "Phone Verified: ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Icon(
                            isPhoneVerified ? Icons.verified : Icons.error,
                            size: 16,
                            color: isPhoneVerified
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// EDIT
            _tile(
              Icons.edit,
              "Edit Profile",
              onTap: () => _editDialog(context, data),
            ),

            /// AVAILABILITY
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.toggle_on, color: Color(0xff1D4ED8)),
                      const SizedBox(width: 10),
                      Text(
                        isAvailable ? "Available (Online)" : "Offline",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  Switch(
                    value: isAvailable,
                    activeColor: const Color(0xff1D4ED8),
                    onChanged: (value) async {
                      await firestore.collection("workers").doc(uid).update({
                        "isAvailable": value,
                      });
                    },
                  ),
                ],
              ),
            ),

            /// OTP VERIFY
            if (!isPhoneVerified)
              _tile(
                Icons.phone_android,
                "Verify Phone",
                onTap: () => _showOtpDialog(context),
              ),

            /// LOGOUT
            _tile(
              Icons.logout,
              "Logout",
              isDanger: true,
              onTap: () async {
                await auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// EDIT PROFILE
  void _editDialog(BuildContext context, Map<String, dynamic> data) {
    TextEditingController name = TextEditingController(text: data['name']);
    TextEditingController skill = TextEditingController(text: data['skill']);
    TextEditingController exp = TextEditingController(text: data['experience']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name),
            TextField(controller: skill),
            TextField(controller: exp),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await firestore.collection("workers").doc(uid).update({
                "name": name.text,
                "skill": skill.text,
                "experience": exp.text,
              });

              await firestore.collection("users").doc(uid).update({
                "name": name.text,
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// OTP DIALOG
  void _showOtpDialog(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController otpController = TextEditingController();

    final otpService = OtpService();
    bool otpSent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Verify Phone"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!otpSent)
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                  if (otpSent)
                    TextField(
                      controller: otpController,
                      decoration: const InputDecoration(labelText: "OTP"),
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (!otpSent) {
                      await otpService.sendOtp(
                        "+91${phoneController.text.trim()}",
                      );
                      setState(() => otpSent = true);
                    } else {
                      await otpService.verifyOtp(otpController.text.trim());

                      await firestore.collection("workers").doc(uid).update({
                        "phone": "+91${phoneController.text.trim()}",
                        "isPhoneVerified": true,
                      });

                      await firestore.collection("users").doc(uid).update({
                        "phone": "+91${phoneController.text.trim()}",
                        "isPhoneVerified": true,
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text(otpSent ? "Verify" : "Send OTP"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _tile(
    IconData icon,
    String text, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDanger ? Colors.red : const Color(0xff1D4ED8),
        ),
        title: Text(text),
      ),
    );
  }
}

/// ================= REQUEST =================

class RequestTab extends StatelessWidget {
  const RequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getWorkerRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];

            return Card(
              child: ListTile(
                title: Text(job['skill']),
                subtitle: Text(job['userEmail']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => db.acceptJob(job.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => db.rejectJob(job.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ================= HISTORY =================

class WorkerHistoryTab extends StatelessWidget {
  const WorkerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getWorkerHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Active Jobs"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];
            var data = job.data() as Map<String, dynamic>;

            bool otpVerified = data['otpVerified'] ?? false;

            TextEditingController otpController = TextEditingController();

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Text(
                    data['skill'] ?? "No Skill",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text("Client: ${data['userEmail']}"),
                  Text("Status: ${data['status']}"),

                  const SizedBox(height: 10),

                  /// 🔐 OTP INPUT (ONLY IF NOT VERIFIED)
                  if (!otpVerified)
                    Column(
                      children: [
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Enter OTP from User",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = await db.verifyJobOtp(
                                jobId: job.id,
                                enteredOtp: otpController.text.trim(),
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("OTP Verified ✅"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid OTP ❌"),
                                  ),
                                );
                              }
                            },
                            child: const Text("Verify OTP"),
                          ),
                        ),
                      ],
                    ),

                  /// ✅ VERIFIED STATE
                  if (otpVerified)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "OTP Verified ✅",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
