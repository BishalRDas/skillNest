import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseService {
  Future<void> submitReview({
    required String jobId,
    required String workerId,
    required String userId,
    required int rating,
    required String reviewText,
  }) async {
    final jobRef = _firestore.collection('jobs').doc(jobId);

    final jobSnap = await jobRef.get();
    if (!jobSnap.exists) throw Exception("Job not found");

    final jobData = jobSnap.data()!;

    if (jobData['status'] != 'completed') {
      throw Exception("Job not completed");
    }

    if (jobData['isReviewed'] == true) {
      throw Exception("Already reviewed");
    }

    final reviewRef = _firestore.collection('reviews').doc();

    await _firestore.runTransaction((transaction) async {
      final workerRef = _firestore.collection('workers').doc(workerId.trim());

      /// ✅ READ FIRST
      final workerSnap = await transaction.get(workerRef);

      if (!workerSnap.exists) {
        throw Exception("Worker not found");
      }

      double currentAvg = (workerSnap.data()?['averageRating'] ?? 0).toDouble();

      int totalReviews = (workerSnap.data()?['totalReviews'] ?? 0);

      double newAvg =
          ((currentAvg * totalReviews) + rating) / (totalReviews + 1);

      newAvg = double.parse(newAvg.toStringAsFixed(1));

      /// ✅ WRITE AFTER READ
      transaction.set(reviewRef, {
        'jobId': jobId,
        'workerId': workerId.trim(),
        'userId': userId.trim(),
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(jobRef, {'isReviewed': true});

      transaction.update(workerRef, {
        'averageRating': newAvg,
        'totalReviews': totalReviews + 1,
      });
    });
  }

  Stream<QuerySnapshot> getWorkerReviews(String workerId) {
    return _firestore
        .collection('reviews')
        .where('workerId', isEqualTo: workerId.trim())
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  bool canReview(Map<String, dynamic> job) {
    return job['status'] == 'completed' && job['isReviewed'] != true;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // GET ALL WORKERS (FILTERED)
  // ===============================
  Stream<QuerySnapshot> getWorkers(String userLocation) {
    return _firestore
        .collection('workers')
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .where('isPhoneVerified', isEqualTo: true)
        .where('location', isEqualTo: userLocation) // ✅ ADD THIS LINE
        .where("isWorking", isEqualTo: false)
        .snapshots();
  }

  // ===============================
  // SEND JOB REQUEST
  // ===============================
  Future sendJobRequest({
    required String workerId,
    required String workerName,
    required String skill,
    required int hours,
    required double charge,
    required double totalPrice,

    // ✅ NEW
    required String bookingDate,
    required String bookingSlot,
  }) async {
    final user = _auth.currentUser!;

    await _firestore.collection("jobs").add({
      "userId": user.uid.trim(),
      "workerId": workerId.trim(),

      "userEmail": user.email,
      "workerName": workerName,

      "skill": skill,
      "status": "pending",

      // 🔥 PAYMENT DATA
      "hours": hours,
      "charge": charge,
      "totalPrice": totalPrice,

      "paymentStatus": "pending",

      // ✅ BOOKING DATA
      "bookingDate": bookingDate,
      "bookingSlot": bookingSlot,

      "jobOtp": null,
      "otpVerified": false,

      "createdAt": FieldValue.serverTimestamp(),

      "isReviewed": false,
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
        .snapshots();
  }

  // ===============================
  // GET ALL TIME SLOTS
  // ===============================
  Stream<QuerySnapshot> getAllSlots() {
    return _firestore
        .collection("slots")
        .where("isActive", isEqualTo: true)
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

    /// GET JOB
    final jobDoc = await _firestore.collection("jobs").doc(jobId).get();

    final data = jobDoc.data()!;

    final userId = data['userId'];

    final workerId = data['workerId'];

    /// REJECT OTHER PENDING JOBS
    var oldJobs = await _firestore
        .collection("jobs")
        .where("userId", isEqualTo: userId)
        .where("status", isEqualTo: "pending")
        .get();

    for (var doc in oldJobs.docs) {
      if (doc.id != jobId) {
        await doc.reference.update({"status": "rejected"});
      }
    }

    /// ACCEPT CURRENT JOB
    await _firestore.collection("jobs").doc(jobId).update({
      "status": "accepted",

      "jobOtp": otp,

      "otpVerified": false,

      "updatedAt": FieldValue.serverTimestamp(),
    });

    /// ✅ UPDATE WORKER TABLE
    await _firestore.collection("workers").doc(workerId).update({
      "isWorking": true,
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
    try {
      print("COMPLETE JOB STARTED");

      final doc = await _firestore.collection("jobs").doc(jobId).get();

      final data = doc.data();

      print("JOB DATA: $data");

      if (data == null) return;

      if (data['otpVerified'] != true) {
        throw Exception("OTP not verified");
      }

      final workerId = data['workerId'];

      print("WORKER ID = $workerId");

      await _firestore.collection("jobs").doc(jobId).update({
        "status": "completed",
        "paymentStatus": "paid",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      print("JOB UPDATED");

      await _firestore.collection("workers").doc(workerId).update({
        "isWorking": false,
      });

      print("WORKER UPDATED SUCCESSFULLY");
    } catch (e) {
      print("ERROR OCCURRED: $e");
    }
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
