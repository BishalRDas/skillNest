import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // GET ALL WORKERS (FILTERED)
  // ===============================
  Stream<QuerySnapshot> getWorkers() {
    return _firestore
        .collection('workers')
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .where('isPhoneVerified', isEqualTo: true)
        .snapshots();
  }

  // ===============================
  // SEND JOB REQUEST
  // ===============================
  Future sendJobRequest({
    required String workerId,
    required String workerName,
    required String skill,
  }) async {
    final user = _auth.currentUser!;

    await _firestore.collection("jobs").add({
      "userId": user.uid.trim(),
      "workerId": workerId.trim(),
      "userEmail": user.email,
      "workerName": workerName,
      "skill": skill.isEmpty ? "General Service" : skill,
      "status": "pending",

      // 🔥 NEW
      "jobOtp": null,
      "otpVerified": false,

      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // USER HISTORY
  // ===============================
  Stream<QuerySnapshot> getUserHistory() {
    final user = _auth.currentUser!;

    return _firestore
        .collection("jobs")
        .where("userId", isEqualTo: user.uid.trim())
        .snapshots();
  }

  // ===============================
  // WORKER REQUESTS (Pending)
  // ===============================
  Stream<QuerySnapshot> getWorkerRequests() {
    final worker = _auth.currentUser!;

    return _firestore
        .collection("jobs")
        .where("workerId", isEqualTo: worker.uid.trim())
        .where("status", isEqualTo: "pending")
        .snapshots();
  }

  // ===============================
  // WORKER HISTORY (Accepted)
  // ===============================
  Stream<QuerySnapshot> getWorkerHistory() {
    final worker = _auth.currentUser!;

    return _firestore
        .collection("jobs")
        .where("workerId", isEqualTo: worker.uid.trim())
        .where("status", isEqualTo: "accepted")
        .snapshots();
  }

  // ===============================
  // 🔐 GENERATE OTP
  // ===============================
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // ===============================
  // ACCEPT JOB (WITH OTP)
  // ===============================
  Future acceptJob(String jobId) async {
    final otp = _generateOtp();

    await _firestore.collection("jobs").doc(jobId).update({
      "status": "accepted",
      "jobOtp": otp, // 🔥 OTP generated here
      "otpVerified": false,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // VERIFY OTP (WORKER SIDE)
  // ===============================
  Future<bool> verifyJobOtp({
    required String jobId,
    required String enteredOtp,
  }) async {
    final doc = await _firestore.collection("jobs").doc(jobId).get();

    final data = doc.data();

    if (data == null) return false;

    final realOtp = data['jobOtp'];

    if (enteredOtp == realOtp) {
      await _firestore.collection("jobs").doc(jobId).update({
        "otpVerified": true,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      return true;
    }

    return false;
  }

  // ===============================
  // COMPLETE JOB (USER SIDE)
  // ===============================
  Future completeJob(String jobId) async {
    final doc = await _firestore.collection("jobs").doc(jobId).get();

    final data = doc.data();

    if (data == null) return;

    if (data['otpVerified'] != true) {
      throw Exception("OTP not verified");
    }

    await _firestore.collection("jobs").doc(jobId).update({
      "status": "completed",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // REJECT JOB
  // ===============================
  Future rejectJob(String jobId) async {
    await _firestore.collection("jobs").doc(jobId).update({
      "status": "rejected",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // ADMIN - ALL JOBS
  // ===============================
  Stream<QuerySnapshot> getAllJobs() {
    return _firestore.collection("jobs").snapshots();
  }
}

Future<String> uploadProfileImage(File file, String uid) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('profile_images')
      .child('$uid.jpg');

  await ref.putFile(file);

  return await ref.getDownloadURL();
}
