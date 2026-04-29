import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_link.dart';
import '../models/patient_request.dart';

class PsychiatristService {
  PsychiatristService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('patient_requests');
  CollectionReference<Map<String, dynamic>> get _patients =>
      _firestore.collection('patients');

  Stream<List<Map<String, dynamic>>> getVerifiedPsychiatrists() {
    return _users
        .where('role', isEqualTo: 'psychiatrist')
        .where('is_verified', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  Future<String?> sendRequest({
    required String userId,
    required String psychiatristId,
  }) async {
    if (userId.trim().isEmpty || psychiatristId.trim().isEmpty) {
      return 'Missing user or psychiatrist id.';
    }

    final existingRequests = await _requests
        .where('user_id', isEqualTo: userId)
        .where('psychiatrist_id', isEqualTo: psychiatristId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();

    if (existingRequests.docs.isNotEmpty) {
      return 'A request already exists with this psychiatrist.';
    }

    final existingPatients = await _patients
        .where('user_id', isEqualTo: userId)
        .where('psychiatrist_id', isEqualTo: psychiatristId)
        .limit(1)
        .get();

    if (existingPatients.docs.isNotEmpty) {
      return 'You are already connected with this psychiatrist.';
    }

    final doc = _requests.doc();
    await doc.set({
      'id': doc.id,
      'user_id': userId,
      'psychiatrist_id': psychiatristId,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });

    return null;
  }

  Stream<List<PatientLink>> getPatients(String psychiatristId) {
    return _patients
        .where('psychiatrist_id', isEqualTo: psychiatristId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientLink.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<PatientRequest>> getPendingRequests(String psychiatristId) {
    return _requests
        .where('psychiatrist_id', isEqualTo: psychiatristId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> acceptRequest(String requestId) async {
    final requestDoc = await _requests.doc(requestId).get();
    if (!requestDoc.exists) {
      return;
    }
    final data = requestDoc.data();
    if (data == null) {
      return;
    }

    final userId = data['user_id'] as String? ?? '';
    final psychiatristId = data['psychiatrist_id'] as String? ?? '';
    if (userId.isEmpty || psychiatristId.isEmpty) {
      return;
    }

    await _requests.doc(requestId).update({'status': 'accepted'});

    final userSnapshot = await _users.doc(userId).get();
    final userData = userSnapshot.data();
    final userName = userData?['name'] as String? ?? 'Unknown';

    final patientId = '${psychiatristId}_$userId';
    await _patients.doc(patientId).set({
      'id': patientId,
      'psychiatrist_id': psychiatristId,
      'user_id': userId,
      'user_name': userName,
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> rejectRequest(String requestId) async {
    await _requests.doc(requestId).update({'status': 'rejected'});
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
