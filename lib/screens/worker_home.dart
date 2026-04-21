import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/otp_service.dart';
import 'login_screen.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
      backgroundColor: const Color(0xffF4F6F9), // slightly cooler light grey
      body: Stack(
        children: [
          // Premium Gradient Header
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Darker rich blue to vibrant blue
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(child: pages[currentIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.person_outline, Icons.person, "Profile", 0),
                _navItem(Icons.work_outline, Icons.work, "Requests", 1),
                _navItem(Icons.history_outlined, Icons.history, "History", 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData iconOutlined, IconData iconFilled, String label, int index) {
    bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffeff6ff) : Colors.transparent, // faint blue bg
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? iconFilled : iconOutlined,
              color: selected ? const Color(0xFF1D4ED8) : Colors.grey.shade400,
              size: 26,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// ================= ACCOUNT =================

class WorkerAccountTab extends StatelessWidget {
  WorkerAccountTab({super.key});

  final auth = AuthService();
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid.trim();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("workers").doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        bool isApproved = data['isApproved'] ?? false;
        bool isAvailable = data['isAvailable'] ?? false;
        bool isPhoneVerified = data['isPhoneVerified'] ?? false;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            /// MAIN PROFILE CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: data['profileImage'] != null
                              ? MemoryImage(base64Decode(data['profileImage']))
                              : null,
                          child: data['profileImage'] == null
                              ? const Icon(Icons.person, color: Color(0xff1D4ED8), size: 30)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? "Worker Name",
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['email'] ?? "",
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${((data['averageRating'] ?? 0).toDouble()).toStringAsFixed(1)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  " (${data['totalReviews'] ?? 0} reviews)",
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Info Chips Row 1
                  Row(
                    children: [
                      Expanded(child: _infoChip("Skill", data['skill'] ?? "Not Set", Icons.work_outline)),
                      const SizedBox(width: 15),
                      Expanded(child: _infoChip("Exp.", data['experience'] ?? "Not Set", Icons.timeline)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Info Chips Row 2
                  Row(
                    children: [
                      Expanded(child: _infoChip("Charges", "₹${data['charges'] ?? 0}/hr", Icons.currency_rupee)),
                      const SizedBox(width: 15),
                      Expanded(child: _infoChip("Location", data['location'] ?? "Not set", Icons.location_on_outlined)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF4F6F9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isApproved ? Icons.verified_user : Icons.pending_actions,
                              size: 18,
                              color: isApproved ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isApproved ? "Approved" : "Pending Approval",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isApproved ? Colors.green[700] : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        if (isPhoneVerified)
                          Row(
                            children: [
                              const Icon(Icons.phone_android, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              const Text("Verified", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// AVAILABILITY CARD
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.power_settings_new,
                          color: isAvailable ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Working Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            isAvailable ? "Available for jobs" : "Currently Offline",
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isAvailable,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade200,
                    onChanged: (value) async {
                      await firestore.collection("workers").doc(uid).update({"isAvailable": value});
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Preferences",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),

            /// SETTINGS
            _tile(Icons.edit_outlined, "Edit Profile", onTap: () => _editDialog(context, data)),
            _tile(Icons.currency_rupee_outlined, "Update Charges", onTap: () => _editChargesDialog(context, data)),
            _tile(Icons.location_on_outlined, "Set Work Location", onTap: () => _openLocationPicker(context)),
            _tile(Icons.image_outlined, "Upload Profile Picture", onTap: () => _uploadProfileImage(context)),

            if (!isPhoneVerified)
              _tile(Icons.phone_android_outlined, "Verify Phone Number", onTap: () => _showOtpDialog(context)),

            const SizedBox(height: 10),

            _tile(
              Icons.logout_rounded,
              "Logout out of Skillnest",
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

  /// COMPRESS + BASE64
  Future<String> compressAndConvertToBase64(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 40,
      minWidth: 300,
      minHeight: 300,
    );

    if (compressedBytes == null) throw Exception("Compression failed");

    return base64Encode(compressedBytes);
  }

  Future<void> _uploadProfileImage(BuildContext context) async {
    final file = await _pickImage();
    if (file == null) return;

    try {
      String base64Image = await compressAndConvertToBase64(file);

      if (base64Image.length > 900000) {
        throw Exception("Image too large");
      }

      await firestore.collection("workers").doc(uid).update({
        "profileImage": base64Image,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile Updated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openLocationPicker(BuildContext context) {
    LatLng? selectedLatLng;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Work Location"),
            content: SizedBox(
              height: 300,
              width: double.maxFinite,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(26.1445, 91.7362),
                  initialZoom: 13,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedLatLng = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.skillnest.app',
                  ),
                  if (selectedLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLatLng!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedLatLng == null) return;

                  List<Placemark> placemarks = await placemarkFromCoordinates(
                    selectedLatLng!.latitude,
                    selectedLatLng!.longitude,
                  );

                  String city = (placemarks.first.locality ?? "unknown")
                      .toLowerCase()
                      .trim();

                  await firestore.collection("workers").doc(uid.trim()).update({
                    "lat": selectedLatLng!.latitude,
                    "lng": selectedLatLng!.longitude,
                    "location": city,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Save Location"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// EDIT PROFILE
  void _editDialog(BuildContext context, Map<String, dynamic> data) {
    TextEditingController name = TextEditingController(text: data['name']);
    TextEditingController skill = TextEditingController(text: data['skill']);
    TextEditingController exp = TextEditingController(text: data['experience']);
    TextEditingController charge = TextEditingController(
      text: (data['charges'] ?? "").toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: skill,
              decoration: const InputDecoration(labelText: "Skill"),
            ),
            TextField(
              controller: exp,
              decoration: const InputDecoration(labelText: "Experience"),
            ),

            /// ✅ ADD THIS
            TextField(
              controller: charge,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Charges (per hour)",
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await firestore.collection("workers").doc(uid).update({
                "name": name.text,
                "skill": skill.text,
                "experience": exp.text,
                "charges": int.tryParse(charge.text) ?? 0,
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

  void _editChargesDialog(BuildContext context, Map<String, dynamic> data) {
    TextEditingController chargeController = TextEditingController(
      text: (data['charges'] ?? 0).toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Charges"),
        content: TextField(
          controller: chargeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Charges per hour",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              int charge = int.tryParse(chargeController.text.trim()) ?? 0;

              if (charge <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter valid amount")),
                );
                return;
              }

              await firestore.collection("workers").doc(uid).update({
                "charges": charge,
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

  Widget _infoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6F9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1D4ED8)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String text, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDanger ? Colors.red.withOpacity(0.1) : const Color(0xFF1D4ED8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDanger ? Colors.red : const Color(0xFF1D4ED8),
            size: 22,
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDanger ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
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

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          job['skill'],
                          style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.schedule, color: Colors.grey, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Requested by:\n${job['userEmail']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => db.rejectJob(job.id),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text("Decline"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => db.acceptJob(job.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text("Accept"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
            bool isPaid = data['paymentStatus'] == "paid";

            TextEditingController otpController = TextEditingController();

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffF4F6F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data['skill'] ?? "Skill",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isPaid ? Colors.green.shade200 : Colors.orange.shade200),
                        ),
                        child: Text(
                          isPaid ? "PAID" : "PENDING",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  
                  Text(
                    "Client: ${data['userEmail']}",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status: ${data['status']}",
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
                      ),
                      Text(
                        "₹${data['totalPrice'] ?? 0}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D4ED8)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🔐 OTP INPUT (ONLY IF NOT VERIFIED)
                  if (!otpVerified)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Job Verification",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter OTP",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  bool success = await db.verifyJobOtp(
                                    jobId: job.id,
                                    enteredOtp: otpController.text.trim(),
                                  );

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("OTP Verified ✅"), backgroundColor: Colors.green),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Invalid OTP ❌"), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D4ED8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                                child: const Text("Verify"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  /// ✅ VERIFIED STATE
                  if (otpVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Job Verified successfully",
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                          ),
                        ],
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
