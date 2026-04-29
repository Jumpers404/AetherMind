/// JournalService
///
/// Thin Firestore-backed persistence layer for JournalEntry objects.
///
/// Responsibilities:
/// - Save journal entries with server timestamping
/// - Retrieve recent or user-scoped journals
/// - Delete entries
///
/// Notes:
/// - Queries assume a `user_id` field exists on saved documents and may
///   require composite Firestore indexes (Firestore will provide a link to
///   create them when a query fails).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';

class JournalService {
  JournalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('journals');

  Future<void> saveJournal(JournalEntry entry) async {
    try {
      print('SERVICE: Writing to Firestore...');
      print('Saving journal for UID: ${entry.userId}');
      final data = entry.toMap();
      data['keystroke_emotion'] = entry.keystrokeEmotion;
      data['keystroke_confidence'] = entry.keystrokeConfidence;
      data['timestamp'] = FieldValue.serverTimestamp();
      await _collection.doc(entry.id).set(data);
      print('SERVICE: Write successful');
    } catch (error) {
      print('SERVICE ERROR: $error');
    }
  }

  Future<List<JournalEntry>> getUserJournals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('SERVICE: No authenticated user for getUserJournals');
        return <JournalEntry>[];
      }
      print('Current UID: ${user.uid}');
      // Note: Firestore may require a composite index for (user_id, timestamp).
      // If this query fails, the error message includes a link to create it.
      final snapshot = await _collection
          .where('user_id', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList();
    } catch (error) {
      print('JournalService.getUserJournals error: $error');
      return <JournalEntry>[];
    }
  }

  Future<List<JournalEntry>> getRecentJournals(int days) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('SERVICE: No authenticated user for getRecentJournals');
        return <JournalEntry>[];
      }
      print('Current UID: ${user.uid}');
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );

      final snapshot = await _collection
          .where('user_id', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList();
    } catch (error) {
      print('JournalService.getRecentJournals error: $error');
      return <JournalEntry>[];
    }
  }

  Future<List<JournalEntry>> getJournalsForUser(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return <JournalEntry>[];
      }

      final snapshot = await _collection
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList();
    } catch (error) {
      print('JournalService.getJournalsForUser error: $error');
      return <JournalEntry>[];
    }
  }

  Future<void> deleteJournal(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (error) {
      print('JournalService.deleteJournal error: $error');
    }
  }
}
