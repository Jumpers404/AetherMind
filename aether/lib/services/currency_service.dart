import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return 0;
    
    return doc.data()?['coins'] ?? 0;
  }

  Future<void> addCoins(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        transaction.set(userRef, {'coins': amount});
      } else {
        final currentCoins = snapshot.data()?['coins'] ?? 0;
        transaction.update(userRef, {'coins': currentCoins + amount});
      }
    });
  }

  Stream<int> coinsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['coins'] ?? 0);
  }
}
