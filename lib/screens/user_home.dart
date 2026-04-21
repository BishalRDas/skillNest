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

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
                _navItem(Icons.history_outlined, Icons.history, "History", 1),
                _navItem(Icons.search_outlined, Icons.search, "Search", 2),
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
              child: Row(
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
                          name,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        if (phone.isNotEmpty)
                          Row(
                            children: [
                              Text(
                                phone,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isVerified ? Icons.verified : Icons.error,
                                size: 16,
                                color: isVerified
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Preferences",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),

            _tile(
              Icons.edit_outlined,
              "Edit Profile",
              onTap: () => _showEditDialog(context, uid, data),
            ),

            _tile(
              Icons.image_outlined,
              "Upload Profile Picture",
              onTap: () => _uploadProfileImage(context, uid),
            ),

            if (!isVerified)
              _tile(
                Icons.phone_android_outlined,
                "Verify Phone Number",
                onTap: () => _showOtpDialog(context, uid),
              ),

            _tile(Icons.settings_outlined, "Settings"),

            _tile(
              Icons.location_on_outlined,
              "Set Location",
              onTap: () => _openLocationPicker(context, uid),
            ),

            const SizedBox(height: 10),

            _tile(
              Icons.logout_rounded,
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

  void _openLocationPicker(BuildContext context, String uid) {
    LatLng? selectedLatLng;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Your Location"),
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

                  String city =
                      (placemarks.first.locality ??
                              placemarks.first.subAdministrativeArea ??
                              placemarks.first.administrativeArea ??
                              "unknown")
                          .toLowerCase()
                          .trim();

                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid.trim())
                      .update({
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

  /// IMAGE PICK
  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> _uploadProfileImage(BuildContext context, String uid) async {
    final file = await _pickImage();
    if (file == null) return;

    try {
      String base64Image = await compressAndConvertToBase64(file);

      /// 🔥 SAFETY CHECK (VERY IMPORTANT)
      if (base64Image.length > 900000) {
        throw Exception("Image too large. Choose smaller image.");
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
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
            data['id'] = job.id; // ✅ ADD THIS

            String status = data['status'] ?? "pending";
            bool otpVerified = data['otpVerified'] ?? false;

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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.work_outline, color: Color(0xff1D4ED8), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            data['workerName'] ?? "Worker",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['paymentStatus'] == "paid" ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: data['paymentStatus'] == "paid" ? Colors.green.shade200 : Colors.orange.shade200),
                        ),
                        child: Text(
                          data['paymentStatus'] == "paid" ? "PAID" : "PENDING",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: data['paymentStatus'] == "paid" ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 13),
                      ),
                      Text(
                        "₹${data['totalPrice'] ?? 0}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1D4ED8)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🔐 SHOW OTP (ONLY USER)
                  if (status == "accepted" && otpVerified == false)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Share this OTP to start work",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data['jobOtp'] ?? "---",
                            style: TextStyle(
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Waiting for worker to verify...",
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  /// 💳 READY TO COMPLETE
                  if (status == "accepted" && otpVerified == true)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "OTP Verified. Job in progress.",
                                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await db.completeJob(job.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Job Completed", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Complete Job", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// ✅ COMPLETED STATE
                  if (status == "completed")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Job Completed Successfully",
                                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          /// ⭐ REVIEW BUTTON
                          if (db.canReview({...data, "id": job.id})) ...[
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showReviewDialog(context, job.id, data);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade500,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.star, size: 18),
                                label: const Text("Rate Worker", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],

                          /// ✅ ALREADY REVIEWED
                          if (data['isReviewed'] == true) ...[
                            const SizedBox(height: 10),
                            const Text(
                              "You have reviewed this worker.",
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
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

/// ================= SEARCH =================
/// (UNCHANGED)
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    Future<String> getUserLocation() async {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid.trim())
          .get();

      return (doc.data()?['location'] ?? "").toString().toLowerCase().trim();
    }

    return FutureBuilder<String>(
      future: getUserLocation(),
      builder: (context, locationSnap) {
        if (!locationSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        String userLocation = locationSnap.data ?? "";

        /// 🔥 IMPORTANT SAFETY CHECK
        if (userLocation.isEmpty) {
          return const Center(child: Text("Please set your location first"));
        }

        /// 🔍 DEBUG (remove later)
        print("User Location: $userLocation");

        return StreamBuilder<QuerySnapshot>(
          stream: db.getWorkers(userLocation),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var workers = snapshot.data!.docs;

            /// 🔍 DEBUG
            print("Workers count: ${workers.length}");

            if (workers.isEmpty) {
              return const Center(child: Text("No workers found in your area"));
            }

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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: data['profileImage'] != null
                                ? MemoryImage(base64Decode(data['profileImage']))
                                : null,
                            child: data['profileImage'] == null
                                ? const Icon(
                                    Icons.person,
                                    color: Color(0xff1D4ED8),
                                    size: 26,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? "No Name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data['skill'] ?? "Skill",
                                  style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${((data['averageRating'] ?? 0).toDouble()).toStringAsFixed(1)}",
                                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1D4ED8)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// 🔽 ADD THIS AT THE VERY BOTTOM OF YOUR FILE

class WorkerDetailScreen extends StatefulWidget {
  final String workerId;
  final Map<String, dynamic> data;

  const WorkerDetailScreen({
    super.key,
    required this.workerId,
    required this.data,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final db = DatabaseService();
  final TextEditingController hoursController = TextEditingController();

  double totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final workerId = widget.workerId;
    print("Worker Data: $data");

    double charge = (data['charges'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text("Worker Details")),
      body: SingleChildScrollView(
        // ✅ FIX 1: prevent blank screen
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// PROFILE
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                backgroundImage: data['profileImage'] != null
                    ? MemoryImage(base64Decode(data['profileImage']))
                    : null,
                child: data['profileImage'] == null
                    ? const Icon(Icons.person, color: Color(0xff1D4ED8))
                    : null,
              ),

              const SizedBox(height: 15),

              Text(
                data['name'] ?? "No Name", // ✅ FIX 2: null safety
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              /// ⭐ AVERAGE RATING
              Text(
                "⭐ ${((data['averageRating'] ?? 0).toDouble()).toStringAsFixed(1)} "
                "(${data['totalReviews'] ?? 0} reviews)",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 5),

              Text(data['skill'] ?? "No Skill"),

              const SizedBox(height: 10),

              /// 💰 CHARGES
              Text(
                charge == 0
                    ? "No charges set"
                    : "₹$charge / hour", // ✅ FIX 3: fallback UI
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// DETAILS
              _infoTile("Phone", data['phone'] ?? "Not provided"),
              _infoTile("Experience", data['experience'] ?? "Not provided"),
              _infoTile(
                "Availability",
                data['isAvailable'] == true ? "Available" : "Offline",
              ),

              const SizedBox(height: 20),

              /// ⏱ HOURS INPUT
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Hours",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              /// 🧮 CALCULATE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    int hours = int.tryParse(hoursController.text) ?? 0;

                    setState(() {
                      totalPrice = hours * charge;
                    });
                  },
                  child: const Text("Calculate Price"),
                ),
              ),

              const SizedBox(height: 10),

              /// 💵 TOTAL
              Text(
                "Total: ₹$totalPrice",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20), // ✅ FIX 4: replace Spacer()
              /// 📦 HIRE (UNCHANGED)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    int hours = int.tryParse(hoursController.text) ?? 0;

                    if (hours == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter valid hours")),
                      );
                      return;
                    }

                    double total = hours * charge;

                    await db.sendJobRequest(
                      workerId: workerId,
                      workerName: data['name'] ?? "Unknown",
                      skill: data['skill'] ?? "General Service",
                      hours: hours,
                      charge: charge,
                      totalPrice: total,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Job Request Sent")),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text("Hire Worker"),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
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

//Review

void showReviewDialog(
  BuildContext context,
  String jobId,
  Map<String, dynamic> job,
) {
  final db = DatabaseService();

  int rating = 5;
  TextEditingController reviewController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("Rate Worker"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ⭐ STAR SELECTOR (BETTER UX)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),

              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: "Write your review",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);

                      try {
                        await db.submitReview(
                          jobId: jobId,
                          workerId: job['workerId'],
                          userId: job['userId'],
                          rating: rating,
                          reviewText: reviewController.text.trim(),
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review Submitted ✅")),
                        );
                      } catch (e) {
                        setState(() => isLoading = false);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        );
      },
    ),
  );
}
