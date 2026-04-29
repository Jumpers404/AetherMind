import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  AdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _journals =>
      _firestore.collection('journals');
  CollectionReference<Map<String, dynamic>> get _patients =>
      _firestore.collection('patients');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('patient_requests');

  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _users.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllJournals() {
    return _journals
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllPatientLinks() {
    return _patients.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllRequests() {
    return _requests
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _users.doc(userId).update({'role': role});
  }

  Future<void> toggleVerification(String userId, bool isVerified) async {
    await _users.doc(userId).update({'is_verified': isVerified});
  }

  Future<void> deleteUser(String userId) async {
    await _users.doc(userId).delete();
  }

  Stream<List<Map<String, dynamic>>> getUsers() => getAllUsers();

  Future<void> updateRole(String userId, String role) =>
      updateUserRole(userId, role);

  Future<void> verifyPsychiatrist(String userId, bool isVerified) =>
      toggleVerification(userId, isVerified);
}
