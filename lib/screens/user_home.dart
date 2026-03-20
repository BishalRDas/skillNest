// SAME IMPORTS
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/otp_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int currentIndex = 0;

  final pages = [AccountTab(), const HistoryTab(), const SearchTab()];

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
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.person, 0),
            _navItem(Icons.history, 1),
            _navItem(Icons.search, 2),
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

class AccountTab extends StatelessWidget {
  AccountTab({super.key});

  final AuthService auth = AuthService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final uid = firebaseAuth.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("users").doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        String name = data["name"] ?? "No Name";
        String email = data["email"] ?? "No Email";
        String phone = data["phone"] ?? "";
        bool isVerified = data["isPhoneVerified"] ?? false;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: data['profileImage'] != null
                        ? NetworkImage(data['profileImage'])
                        : null,
                    child: data['profileImage'] == null
                        ? const Icon(Icons.person, color: Color(0xff1D4ED8))
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (phone.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              phone,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isVerified ? Icons.verified : Icons.error,
                              size: 16,
                              color: isVerified
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

            _tile(
              Icons.edit,
              "Edit Profile",
              onTap: () => _showEditDialog(context, uid, data),
            ),

            _tile(
              Icons.image,
              "Upload Profile Picture",
              onTap: () => _uploadProfileImage(context, uid),
            ),

            if (!isVerified)
              _tile(
                Icons.phone_android,
                "Verify Phone Number",
                onTap: () => _showOtpDialog(context, uid),
              ),

            _tile(Icons.settings, "Settings"),

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

  /// IMAGE PICK
  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  /// IMAGE UPLOAD
  Future<void> _uploadProfileImage(BuildContext context, String uid) async {
    final file = await _pickImage();
    if (file == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "profileImage": url,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));
  }

  /// OTP (UNCHANGED)
  void _showOtpDialog(BuildContext context, String uid) {
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
                  if (!otpSent) TextField(controller: phoneController),
                  if (otpSent) TextField(controller: otpController),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (!otpSent) {
                      await otpService.sendOtp("+91${phoneController.text}");
                      setState(() => otpSent = true);
                    } else {
                      await otpService.verifyOtp(otpController.text);

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .update({
                            "phone": "+91${phoneController.text}",
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

  void _showEditDialog(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    TextEditingController nameController = TextEditingController(
      text: data["name"],
    );

    TextEditingController phoneController = TextEditingController(
      text: data["phone"] ?? "",
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Phone (Verified Only)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .update({"name": nameController.text});

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated")),
                );
              },
              child: const Text("Save"),
            ),
          ],
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

/// ================= HISTORY =================
/// ================= HISTORY =================
/// 🔥 UPDATED WITH OTP FLOW

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getUserHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Job History"));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];
            var data = job.data() as Map<String, dynamic>;

            String status = data['status'] ?? "pending";
            bool otpVerified = data['otpVerified'] ?? false;

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
                  Row(
                    children: [
                      const Icon(Icons.work, color: Color(0xff1D4ED8)),
                      const SizedBox(width: 10),
                      Text(
                        data['workerName'] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// STATUS
                  Text("Status: $status"),

                  const SizedBox(height: 10),

                  /// 🔐 SHOW OTP (ONLY USER)
                  if (status == "accepted" && otpVerified == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Share this OTP with worker:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['jobOtp'] ?? "Generating...",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                  /// ⏳ WAITING STATE
                  if (status == "accepted" && otpVerified == false)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Waiting for worker to verify OTP",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),

                  /// 💳 READY TO COMPLETE
                  if (status == "accepted" && otpVerified == true)
                    Column(
                      children: [
                        const SizedBox(height: 10),

                        const Text(
                          "OTP Verified ✅",
                          style: TextStyle(color: Colors.green),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await db.completeJob(job.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Job Completed"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            child: const Text("Complete Job"),
                          ),
                        ),
                      ],
                    ),

                  /// ✅ COMPLETED STATE
                  if (status == "completed")
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Job Completed ✅",
                        style: TextStyle(color: Colors.green),
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

/// ================= SEARCH =================
/// (UNCHANGED)
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getWorkers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var workers = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;

          return (data['isApproved'] ?? false) &&
              (data['isAvailable'] ?? false) &&
              (data['isPhoneVerified'] ?? false);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            var worker = workers[index];
            var data = worker.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkerDetailScreen(workerId: worker.id, data: data),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xff1D4ED8),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data['skill'] ?? "No Skill",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios, size: 16),
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

// 🔽 ADD THIS AT THE VERY BOTTOM OF YOUR FILE

class WorkerDetailScreen extends StatelessWidget {
  final String workerId;
  final Map<String, dynamic> data;

  const WorkerDetailScreen({
    super.key,
    required this.workerId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Worker Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// PROFILE
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xff1D4ED8),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),

            const SizedBox(height: 15),

            Text(
              data['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(data['skill'] ?? "No Skill"),

            const SizedBox(height: 20),

            /// DETAILS
            _infoTile("Phone", data['phone'] ?? "Not provided"),
            _infoTile("Experience", data['experience'] ?? "Not provided"),
            _infoTile(
              "Availability",
              data['isAvailable'] == true ? "Available" : "Offline",
            ),

            const Spacer(),

            /// HIRE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await db.sendJobRequest(
                    workerId: workerId,
                    workerName: data['name'],
                    skill: data['skill'] ?? "General Service",
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Job Request Sent")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Hire Worker"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
