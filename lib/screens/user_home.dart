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
import '../main.dart';

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC), // Premium light grey (Slate 50)
      body: Stack(
        children: [
          // Premium Gradient Header
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1D4ED8), // Blue 700
                  Color(0xFF3B82F6), // Blue 500
                ],
              ),
            ),
          ),
          
          // Pages with slight fade transition
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: pages[currentIndex],
            ),
          ),
        ],
      ),
      extendBody: true, // For floating bottom nav bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937).withOpacity(0.9) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: const Color(0xFF1D4ED8).withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
      ),
    );
  }

  Widget _navItem(
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    int index,
  ) {
    bool selected = currentIndex == index;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color selectedColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    Color unselectedColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withOpacity(0.1) // Soft blue bg
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                selected ? iconFilled : iconOutlined,
                key: ValueKey<bool>(selected),
                color: selected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
        String location = data["location"] ?? "San Francisco, California";

        return Container(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditDialog(context, uid, data),
                      child: Icon(Icons.edit_outlined, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: const Color(0xFF64748B).withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  backgroundImage: data['profileImage'] != null
                                      ? MemoryImage(base64Decode(data['profileImage']))
                                      : null,
                                  child: data['profileImage'] == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Color(0xFF2563EB),
                                          size: 40,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _uploadProfileImage(context, uid),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _infoRow(context, Icons.email_outlined, email),
                                _infoRow(context, Icons.location_on_outlined, location),
                                if (phone.isNotEmpty)
                                  _infoRow(context, Icons.phone_outlined, phone),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        "Account",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: const Color(0xFF64748B).withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _tile(context, Icons.person_outline, "Account Details", onTap: () => _showEditDialog(context, uid, data)),
                          _tile(context, Icons.lock_outline, "Change Password", onTap: () => _showChangePasswordDialog(context)),
                          _tile(context, Icons.location_on_outlined, "Set Location", onTap: () => _openLocationPicker(context, uid)),
                          _tile(
                            context,
                            Icons.dark_mode_outlined,
                            "Theme Mode",
                            showDivider: false,
                            trailing: ValueListenableBuilder<ThemeMode>(
                              valueListenable: MyApp.themeNotifier,
                              builder: (_, ThemeMode currentMode, __) {
                                bool isDarkMode = currentMode == ThemeMode.dark;
                                return Switch(
                                  value: isDarkMode,
                                  onChanged: (val) {
                                    MyApp.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                                  },
                                  activeColor: const Color(0xFF2563EB),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _openLocationPicker(BuildContext context, String uid) {
    LatLng? selectedLatLng;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.grey.shade200,
            title: Text("Select Your Location", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (selectedLatLng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a location")),
                    );
                    return;
                  }

                  setState(() => isLoading = true);
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      selectedLatLng!.latitude,
                      selectedLatLng!.longitude,
                    );

                    String city =
                        (placemarks.isNotEmpty
                                ? placemarks.first.locality ??
                                      placemarks.first.subAdministrativeArea ??
                                      placemarks.first.administrativeArea
                                : "unknown")!
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

                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    print("Location Error: $e");

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to get location")),
                      );
                      setState(() => isLoading = false);
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Save Location"),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String base64Image = await compressAndConvertToBase64(file);

      /// 🔥 SAFETY CHECK (VERY IMPORTANT)
      if (base64Image.length > 900000) {
        throw Exception("Image too large. Choose smaller image.");
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "profileImage": base64Image,
      });

      if (context.mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.grey.shade200,
              title: Text("Verify Phone", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!otpSent) TextField(
                    controller: phoneController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  if (otpSent) TextField(
                    controller: otpController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "OTP",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
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
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    try {
                      if (!otpSent) {
                        await otpService.sendOtp("+91${phoneController.text}");
                        if (context.mounted) {
                          setState(() {
                            otpSent = true;
                            isLoading = false;
                          });
                        }
                      } else {
                        await otpService.verifyOtp(otpController.text);

                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .update({
                              "phone": "+91${phoneController.text}",
                              "isPhoneVerified": true,
                            });

                        if (context.mounted) Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(otpSent ? "Verify" : "Send OTP"),
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

    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isDark = Theme.of(context).brightness == Brightness.dark;
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      enabled: false,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Phone (Verified)",
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setState(() => isLoading = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .update({"name": nameController.text});

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Profile Updated")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              title: Text("Change Password", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Old Password",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
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
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        AuthCredential credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: oldPasswordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPasswordController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Password changed successfully")),
                          );
                          Navigator.pop(context);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Save"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String text, {
    VoidCallback? onTap,
    Widget? trailing,
    bool showDivider = true,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            highlightColor: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  trailing ?? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
            indent: 60,
            endIndent: 20,
          ),
      ],
    );
  }
}

/// ================= HISTORY =================
/// ================= HISTORY =================
/// 🔥 UPDATED WITH OTP FLOW

/// ================= HISTORY =================
/// 🔥 UPDATED WITH MONTH DROPDOWN + TIME

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final Map<String, TextEditingController> _hoursControllers = {};
  final Map<String, bool> _loadingJobs = {};

  @override
  void dispose() {
    for (var controller in _hoursControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getUserHistory(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs.where((job) {
          var data = job.data() as Map<String, dynamic>;
          var status = data['status'] ?? '';
          return status == 'accepted' || status == 'completed';
        }).toList();

        if (jobs.isEmpty) {
          return const Center(child: Text("No Job History"));
        }

        /// ================= GROUP BY MONTH =================
        Map<String, List<QueryDocumentSnapshot>> groupedJobs = {};

        for (var job in jobs) {
          var data = job.data() as Map<String, dynamic>;

          var timestamp = data['createdAt'];

          DateTime date = timestamp != null
              ? (timestamp as Timestamp).toDate()
              : DateTime.now();

          String monthKey =
              "${date.year}-${date.month.toString().padLeft(2, '0')}";

          if (!groupedJobs.containsKey(monthKey)) {
            groupedJobs[monthKey] = [];
          }

          groupedJobs[monthKey]!.add(job);
        }

        /// ================= UI =================
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),

          children: groupedJobs.entries.map((entry) {
            String month = entry.key;

            List<QueryDocumentSnapshot> monthJobs = entry.value;

            return ExpansionTile(
              title: Text(
                month,

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              textColor: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB),
              iconColor: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB),
              collapsedTextColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
              collapsedIconColor: isDark ? Colors.white70 : const Color(0xFF1E293B),

              children: monthJobs.map((job) {
                var data = job.data() as Map<String, dynamic>;

                data['id'] = job.id;

                String status = data['status'] ?? "pending";

                bool otpVerified = data['otpVerified'] ?? false;
                bool isPaid = data['paymentStatus'] == "paid";
                bool isReviewed = data['isReviewed'] ?? false;

                /// ================= DATE + TIME =================
                var timestamp = data['createdAt'];

                DateTime date = timestamp != null
                    ? (timestamp as Timestamp).toDate()
                    : DateTime.now();

                String formattedDate =
                    "${date.day}/${date.month}/${date.year} - "
                    "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9), width: 1.5), // Slate 100
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withOpacity(0.08), // Slate 400
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// 📅 CREATED DATE
                      Text(
                        formattedDate,

                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ================= HEADER =================
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF), // Blue 50
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), // Blue 600
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              data['workerName'] ?? "Worker",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: isDark ? Colors.white : const Color(0xFF1E293B), // Slate 800
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// ================= BOOKING DATE + SLOT =================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC), // Slate 50
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)), // Slate 200
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// BOOKING DATE
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Date: ${data.containsKey('bookingDate') ? data['bookingDate'] : 'Not Selected'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155), // Slate 700
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            /// SLOT
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Color(0xFF10B981), // Emerald 500
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Slot: ${data.containsKey('bookingSlot') ? data['bookingSlot'] : 'Not Selected'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            /// ADDRESS
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Address: ${data.containsKey('address') ? data['address'] : 'Not Provided'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// ================= STATUS =================
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Status: ${status.toUpperCase()}",

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontWeight: FontWeight.w600,

                                color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey,

                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "₹${data['totalPrice'] ?? 0}",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 18,

                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// 🔐 OTP BEFORE VERIFICATION
                      if (otpVerified == false)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C1600) : const Color(0xFFFFF7ED), // Orange 50
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF5E2B00) : const Color(0xFFFFEDD5)), // Orange 100
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.05), // Orange 500
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Share this OTP to start work",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFFFB07C) : const Color(0xFFEA580C), // Orange 600
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  data['jobOtp'] ?? "---",
                                  style: TextStyle(
                                    fontSize: 28,
                                    letterSpacing: 8,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFFFFB07C) : const Color(0xFFC2410C), // Orange 700
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// ✅ SHOW COMPLETE BUTTON AFTER OTP VERIFIED
                      if (otpVerified == true && status != "completed")
                        Builder(
                          builder: (context) {
                            final hoursController = _hoursControllers.putIfAbsent(
                               job.id,
                              () => TextEditingController(),
                            );
                            final bool isJobLoading = _loadingJobs[job.id] ?? false;

                            return Container(
                              width: double.infinity,

                              padding: const EdgeInsets.all(15),

                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF062F16) : Colors.green.shade50,

                                borderRadius: BorderRadius.circular(15),

                                border: Border.all(color: isDark ? const Color(0xFF14532D) : Colors.green.shade200),
                              ),

                              child: Column(
                                children: [
                                  Text(
                                    "Work Started ✅",

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF4ADE80) : Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// ⏱ HOURS WORKED INPUT
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: TextField(
                                      controller: hoursController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                      decoration: InputDecoration(
                                        labelText: "Hours Worked",
                                        hintText: "Enter actual hours worked",
                                        labelStyle: TextStyle(color: isDark ? Colors.green.shade300 : Colors.green.shade700, fontWeight: FontWeight.w600),
                                        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500),
                                        prefixIcon: Icon(Icons.timer_outlined, color: isDark ? Colors.green.shade300 : Colors.green),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: isDark ? const Color(0xFF14532D) : Colors.green.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: isDark ? const Color(0xFF14532D) : Colors.green.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: isDark ? const Color(0xFF4ADE80) : Colors.green, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF111827) : Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: double.infinity,

                                    child: ElevatedButton(
                                      onPressed: isJobLoading ? null : () async {
                                        final hoursStr = hoursController.text.trim();
                                        final int hours = int.tryParse(hoursStr) ?? 0;
                                        if (hours <= 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Please enter valid hours worked"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          _loadingJobs[job.id] = true;
                                        });

                                        try {
                                          double charge = (data['charge'] ?? 0).toDouble();
                                          double totalPrice = hours * charge;

                                          await FirebaseFirestore.instance
                                              .collection("jobs")
                                              .doc(job.id)
                                              .update({
                                                "status": "completed",
                                                "hours": hours,
                                                "totalPrice": totalPrice,
                                                "updatedAt":
                                                    FieldValue.serverTimestamp(),
                                              });

                                          await FirebaseFirestore.instance
                                              .collection("workers")
                                              .doc(data['workerId'])
                                              .update({"isWorking": false});

                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Job Completed ✅"),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _loadingJobs[job.id] = false;
                                            });
                                          }
                                        }
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,

                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),

                                      child: isJobLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text("Complete Job"),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),

                      /// ✅ AFTER COMPLETION
                      /// ✅ AFTER COMPLETION
                      if (status == "completed")
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : Colors.blue.shade50,

                            borderRadius: BorderRadius.circular(15),

                            border: Border.all(color: isDark ? const Color(0xFF1E3A8A) : Colors.blue.shade200),
                          ),

                          child: Column(
                            children: [
                              Text(
                                "Job Completed ✅",

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF60A5FA) : Colors.blue,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// PAYMENT STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? (isDark ? const Color(0xFF062F16) : Colors.green.shade50)
                                      : (isDark ? const Color(0xFF2C1600) : Colors.orange.shade50),

                                  borderRadius: BorderRadius.circular(12),

                                  border: Border.all(
                                    color: isPaid
                                        ? (isDark ? const Color(0xFF14532D) : Colors.green.shade200)
                                        : (isDark ? const Color(0xFF5E2B00) : Colors.orange.shade200),
                                  ),
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Icon(
                                      isPaid
                                          ? Icons.check_circle
                                          : Icons.pending,

                                      color: isPaid
                                          ? (isDark ? const Color(0xFF4ADE80) : Colors.green)
                                          : (isDark ? const Color(0xFFFFB07C) : Colors.orange),
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      isPaid
                                          ? "Payment Verified"
                                          : "Payment Pending",

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,

                                        color: isPaid
                                            ? (isDark ? const Color(0xFF4ADE80) : Colors.green)
                                            : (isDark ? const Color(0xFFFFB07C) : Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ⭐ PREMIUM REVIEW CARD
                              /// ⭐ SHOW RATE BUTTON ONLY AFTER PAYMENT VERIFIED
                              /// ⭐ REVIEW SECTION
                              /// ⭐ REVIEW SECTION
                              if (status == "completed" &&
                                  isPaid &&
                                  !isReviewed)
                                Container(
                                  margin: const EdgeInsets.only(top: 14),

                                  width: double.infinity,

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),

                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [const Color(0xFF2C1600), const Color(0xFF1F1A00)]
                                          : [Colors.amber.shade50, Colors.orange.shade50],

                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),

                                    borderRadius: BorderRadius.circular(18),

                                    border: Border.all(
                                      color: isDark ? const Color(0xFF5E2B00) : Colors.amber.shade200,
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.06),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      /// ⭐ SMALL ICON
                                      Container(
                                        padding: const EdgeInsets.all(10),

                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                          shape: BoxShape.circle,

                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(
                                                0.12,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),

                                        child: const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Colors.amber,
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      /// TEXTS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          mainAxisSize: MainAxisSize.min,

                                          children: [
                                            Text(
                                              "Rate Experience",

                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : const Color(0xFF111827),
                                              ),
                                            ),

                                            const SizedBox(height: 3),

                                            Text(
                                              "Share your service feedback.",

                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: isDark ? Colors.white70 : Colors.grey.shade700,
                                                height: 1.4,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            /// STARS
                                            Wrap(
                                              spacing: 1,

                                              children: List.generate(
                                                5,
                                                (index) => Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber.shade500,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      /// BUTTON
                                      SizedBox(
                                        height: 42,

                                        child: ElevatedButton(
                                          onPressed: () {
                                            showReviewDialog(
                                              context,
                                              job.id,
                                              data,
                                            );
                                          },

                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,

                                            backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFF111827),

                                            foregroundColor: Colors.white,

                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),

                                          child: const Text(
                                            "Rate",

                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              /// ✅ REVIEW SUBMITTED
                              if (status == "completed" && isPaid && isReviewed)
                                Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF062F16) : const Color(0xFFF0FDF4), // Green 50
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)), // Green 100
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF10B981), // Emerald 500
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Review Submitted",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF059669), // Emerald 600
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Thank you for your feedback.",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.white70 : Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}

/// ================= SEARCH =================
/// (UNCHANGED)

/// ================= SEARCH =================

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  /// ✅ PER WORKER SLOT
  Map<String, String?> selectedSlots = {};

  /// ✅ PER WORKER DATE
  Map<String, DateTime?> selectedDates = {};

  /// Filter skill
  String? selectedSkill;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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

        /// 🔍 DEBUG
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

            // 1. Extract unique skills dynamically
            var uniqueSkills = workers
                .map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return (data['skill']?.toString() ?? '').trim();
                })
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();

            // 2. Filter workers by selectedSkill
            var filteredWorkers = selectedSkill == null
                ? workers
                : workers.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return (data['skill']?.toString() ?? '').trim() == selectedSkill;
                  }).toList();

            // 3. Sort workers: lowest price first, then highest rating first
            filteredWorkers.sort((a, b) {
              var aData = a.data() as Map<String, dynamic>;
              var bData = b.data() as Map<String, dynamic>;

              double aPrice = (aData['charges'] ?? 0).toDouble();
              double bPrice = (bData['charges'] ?? 0).toDouble();

              int priceCompare = aPrice.compareTo(bPrice);
              if (priceCompare != 0) {
                return priceCompare;
              }

              double aRating = (aData['averageRating'] ?? 0).toDouble();
              double bRating = (bData['averageRating'] ?? 0).toDouble();
              return bRating.compareTo(aRating);
            });

            return Column(
              children: [
                /// Skill dropdown filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: const Color(0xFF64748B).withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: selectedSkill,
                        hint: Text(
                          "All Skills",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.filter_list_rounded,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              "All Skills",
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          ...uniqueSkills.map((skill) {
                            return DropdownMenuItem<String>(
                              value: skill,
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSkill = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredWorkers.isEmpty
                      ? Center(
                          child: Text(
                            "No workers available for this skill",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),

                          itemCount: filteredWorkers.length,

                          itemBuilder: (context, index) {
                            var worker = filteredWorkers[index];

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
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9), width: 1.5), // Slate 100
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: const Color(0xFF64748B).withOpacity(0.06), // Slate 500
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// PROFILE IMAGE
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
                                            ? MemoryImage(
                                                base64Decode(data['profileImage']),
                                              )
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
                                          /// NAME
                                          Text(
                                            data['name'] ?? "No Name",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A), // Slate 900
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          /// SKILL
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF), // Blue 50
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE)), // Blue 100
                                            ),
                                            child: Text(
                                              data['skill'] ?? "Skill",
                                              style: TextStyle(
                                                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), // Blue 600
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          /// RATING
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFF59E0B), // Amber 500
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${((data['averageRating'] ?? 0).toDouble()).toStringAsFixed(1)}",
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : const Color(0xFF475569), // Slate 600
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          /// ================= SLOT DROPDOWN =================
                                          StreamBuilder<QuerySnapshot>(
                                            stream: db.getAllSlots(),

                                            builder: (context, slotSnapshot) {
                                              if (!slotSnapshot.hasData) {
                                                return const SizedBox();
                                              }

                                              var slots = slotSnapshot.data!.docs;

                                              return DropdownButtonFormField<String>(
                                                value: selectedSlots[worker.id],
                                                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),

                                                decoration: InputDecoration(
                                                  labelText: "Preferred Slot",
                                                  labelStyle: TextStyle(color: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB)),

                                                  filled: true,

                                                  fillColor: isDark ? const Color(0xFF111827) : Colors.grey.shade50,

                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10,
                                                      ),

                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey.shade300),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey.shade300),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                                                  ),
                                                ),

                                                items: slots.map((doc) {
                                                  String slot = doc['slot'];

                                                  return DropdownMenuItem<String>(
                                                    value: slot,

                                                    child: Text(slot),
                                                  );
                                                }).toList(),

                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedSlots[worker.id] = value;
                                                  });
                                                },
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 12),

                                          /// ================= DATE PICKER =================
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              final pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2030),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context).copyWith(
                                                      colorScheme: const ColorScheme.light(
                                                        primary: Color(0xFF2563EB), // header background color
                                                        onPrimary: Colors.white, // header text color
                                                        onSurface: Color(0xFF0F172A), // body text color
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (pickedDate != null) {
                                                setState(() {
                                                  selectedDates[worker.id] = pickedDate;
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.calendar_today, size: 18),
                                            label: Text(
                                              selectedDates[worker.id] == null
                                                  ? "Select Booking Date"
                                                  : selectedDates[worker.id]
                                                        .toString()
                                                        .split(" ")[0],
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2563EB), // Blue 600
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 14,
                                                horizontal: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    /// ARROW
                                    Container(
                                      padding: const EdgeInsets.all(8),

                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF111827) : Colors.grey.shade50,

                                        shape: BoxShape.circle,

                                        border: Border.all(color: isDark ? const Color(0xFF374151) : Colors.grey.shade200),
                                      ),

                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final workerId = widget.workerId;
    print("Worker Data: $data");

    double charge = (data['charges'] ?? 0).toDouble();

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text("Worker Details", style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HERO PROFILE SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], // Slate 900 to Blue 900
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: data['profileImage'] != null
                          ? MemoryImage(base64Decode(data['profileImage']))
                          : null,
                      child: data['profileImage'] == null
                          ? const Icon(Icons.person, color: Color(0xFF1D4ED8), size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['name'] ?? "No Name",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "${((data['averageRating'] ?? 0).toDouble()).toStringAsFixed(1)} (${data['totalReviews'] ?? 0} reviews)",
                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['skill'] ?? "No Skill",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 💰 CHARGES
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: const Color(0xFF64748B).withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hourly Rate",
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        Text(
                          charge == 0 ? "Not set" : "₹$charge / hr",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  /// DETAILS
                  _infoTile("Phone", data['phone'] ?? "Not provided", Icons.phone_outlined),
                  _infoTile("Experience", data['experience'] ?? "Not provided", Icons.work_outline),
                  _infoTile(
                    "Availability",
                    data['isAvailable'] == true ? "Available" : "Offline",
                    Icons.event_available_outlined,
                    isSuccess: data['isAvailable'] == true,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Book Service",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  /// 📦 HIRE BUTTON SECTION
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: const Color(0xFF64748B).withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: addressController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Work Address Location",
                            hintText: "Enter the exact address for the worker",
                            labelStyle: TextStyle(color: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB), fontWeight: FontWeight.w600),
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () async {
                              final address = addressController.text.trim();
                              if (address.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter the work address location"), backgroundColor: Color(0xFFEF4444)),
                                );
                                return;
                              }

                              setState(() => isLoading = true);
                              try {
                                await db.sendJobRequest(
                                  workerId: workerId,
                                  workerName: data['name'] ?? "Unknown",
                                  skill: data['skill'] ?? "General Service",
                                  hours: 0,
                                  charge: charge,
                                  totalPrice: 0.0,
                                  bookingDate: DateTime.now().toString().split(" ")[0],
                                  bookingSlot: "09:00-11:00",
                                  address: address,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Job Request Sent"), backgroundColor: Color(0xFF10B981)),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Hire Worker", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon, {bool isSuccess = false}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isSuccess ? const Color(0xFF10B981) : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isSuccess ? const Color(0xFF10B981) : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
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
  bool isDark = Theme.of(context).brightness == Brightness.dark;

  int rating = 5;
  TextEditingController reviewController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          elevation: 24,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Center(
            child: Text(
              "Rate Experience",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How was your service with this worker?",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              /// ⭐ STAR SELECTOR (BETTER UX)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedScale(
                        scale: index < rating ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: index < rating
                              ? const Color(0xFFF59E0B) // Amber 500
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: reviewController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Write your review...",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            try {
                              await db.submitReview(
                                jobId: jobId,
                                workerId: job['workerId'] ?? "",
                                userId: job['userId'] ?? FirebaseAuth.instance.currentUser!.uid,
                                rating: rating,
                                reviewText: reviewController.text.trim(),
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review Submitted ✅"),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (e) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Submit", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
