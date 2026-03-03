import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // GET ALL WORKERS
  // ===============================
  Stream<QuerySnapshot> getWorkers() {
    return _firestore.collection("workers").snapshots();
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
      "skill": skill,
      "status": "pending",
      "date": FieldValue.serverTimestamp(),
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
  // ACCEPT JOB
  // ===============================
  Future acceptJob(String jobId) async {
    await _firestore.collection("jobs").doc(jobId).update({
      "status": "accepted",
    });
  }

  // ===============================
  // REJECT JOB
  // ===============================
  Future rejectJob(String jobId) async {
    await _firestore.collection("jobs").doc(jobId).update({
      "status": "rejected",
    });
  }

  // ===============================
  // ADMIN - ALL JOBS
  // ===============================
  Stream<QuerySnapshot> getAllJobs() {
    return _firestore.collection("jobs").snapshots();
  }
}
