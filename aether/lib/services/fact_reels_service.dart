import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/fact_model.dart';

class FactReelsService {
  FactReelsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _savedFactsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('saved_facts');
  }

  Future<void> setSavedFact(Fact fact, bool isSaved) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final docRef = _savedFactsCollection(user.uid).doc(fact.id);
    if (isSaved) {
      await docRef.set({
        'id': fact.id,
        'text': fact.text,
        'category': fact.category,
        'tone': fact.tone,
        'background': fact.background.value,
        'textColor': fact.textColor.value,
        'audioUrl': fact.audioUrl,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  Stream<List<Fact>> watchSavedFacts() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Fact>>.empty();
    }
    return _savedFactsCollection(user.uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Fact(
          id: data['id'] as String? ?? doc.id,
          text: data['text'] as String? ?? '',
          category: data['category'] as String? ?? 'Mind',
          tone: data['tone'] as String? ?? 'Reflective',
          background: Color(data['background'] as int? ?? 0xFFFFFFFF),
          textColor: Color(data['textColor'] as int? ?? 0xFF1E1E1E),
          audioUrl: data['audioUrl'] as String? ?? '',
        );
      }).toList();
    });
  }
}
