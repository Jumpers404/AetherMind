import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingService {
  OnboardingService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> saveOnboardingProfile({
    required List<String> interests,
    required List<String> customInterests,
    required Map<String, List<String>> preferences,
    required List<String> reliefMethods,
    required bool completed,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final payload = {
      'onboarding_profile': {
        'interests': interests,
        'custom_interests': customInterests,
        'preferences': {
          'music': preferences['music'] ?? <String>[],
          'movies': preferences['movies'] ?? <String>[],
          'activities': preferences['activities'] ?? <String>[],
        },
        'relief_methods': reliefMethods,
        'created_at': FieldValue.serverTimestamp(),
      },
      'onboarding_completed': completed,
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> markOnboardingSkipped() async {
    await saveOnboardingProfile(
      interests: const [],
      customInterests: const [],
      preferences: const {
        'music': <String>[],
        'movies': <String>[],
        'activities': <String>[],
      },
      reliefMethods: const [],
      completed: false,
    );
  }

  Future<bool> isOnboardingCompleted() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    return data?['onboarding_completed'] == true;
  }

  Future<Map<String, dynamic>?> getOnboardingProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    return data?['onboarding_profile'] as Map<String, dynamic>?;
  }

  Future<void> updateInterests(List<String> interests) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'onboarding_profile.interests': interests,
    });
  }
}
