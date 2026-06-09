import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📥 บันทึกค่าเกรด MP ล่าสุด
  Future<void> saveUserMpData(String uid, int finalGrade, Map<String, String> details) async {
    await _db.collection('users').doc(uid).set({
      'latest_mp_grade': finalGrade,
      'mp_details': details,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true คือการอัปเดตทับเฉพาะฟิลด์ ไม่ลบของเก่า
  }

  // 📤 ดึงค่าเกรด MP ล่าสุด
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
}