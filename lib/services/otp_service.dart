import 'package:firebase_auth/firebase_auth.dart';

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  // Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (Android)
        await _linkCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Verify OTP
  Future<void> verifyOtp(String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _linkCredential(credential);
  }

  // 🔥 Link with existing user (VERY IMPORTANT)
  Future<void> _linkCredential(PhoneAuthCredential credential) async {
    final user = _auth.currentUser;

    if (user != null) {
      await user.linkWithCredential(credential);
    } else {
      throw Exception("User not logged in");
    }
  }
}
