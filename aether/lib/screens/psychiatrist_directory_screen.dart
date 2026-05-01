import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aether/widgets/auth_flow_loader.dart';

import '../app_theme.dart';
import '../services/psychiatrist_service.dart';
import '../widgets/app_card.dart';

class PsychiatristDirectoryScreen extends StatefulWidget {
  const PsychiatristDirectoryScreen({super.key});

  @override
  State<PsychiatristDirectoryScreen> createState() =>
      _PsychiatristDirectoryScreenState();
}

class _PsychiatristDirectoryScreenState
    extends State<PsychiatristDirectoryScreen> {
  final PsychiatristService _service = PsychiatristService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoadingRelations = true;
  Map<String, String> _relationshipStatus = {};

  @override
  void initState() {
    super.initState();
    _loadRelationshipStatus();
  }

  Future<void> _loadRelationshipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _relationshipStatus = {};
        _isLoadingRelations = false;
      });
      return;
    }

    final requests = await _firestore
        .collection('patient_requests')
        .where('user_id', isEqualTo: user.uid)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    final patients = await _firestore
        .collection('patients')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final map = <String, String>{};
    for (final doc in requests.docs) {
      final data = doc.data();
      final psychiatristId = data['psychiatrist_id'] as String? ?? '';
      final status = data['status'] as String? ?? 'pending';
      if (psychiatristId.isNotEmpty) {
        map[psychiatristId] = status;
      }
    }

    for (final doc in patients.docs) {
      final data = doc.data();
      final psychiatristId = data['psychiatrist_id'] as String? ?? '';
      if (psychiatristId.isNotEmpty) {
        map[psychiatristId] = 'accepted';
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _relationshipStatus = map;
      _isLoadingRelations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Find a Psychiatrist',
          style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRelationshipStatus,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _service.getVerifiedPsychiatrists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: const SnakeLoadingIndicator());
            }

            final psychiatrists = snapshot.data ?? <Map<String, dynamic>>[];
            if (psychiatrists.isEmpty) {
              return _buildEmptyState('No verified psychiatrists available.');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: psychiatrists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final psychiatrist = psychiatrists[index];
                final id = psychiatrist['id'] as String? ?? '';
                final name = psychiatrist['name'] as String? ?? 'Unknown';
                final email = psychiatrist['email'] as String? ?? '';
                final status = _relationshipStatus[id];

                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_pin_circle_rounded,
                          color: Color(0xFF3AA891),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.bodyPrimary),
                            const SizedBox(height: 2),
                            Text(email, style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                      _buildStatusAction(id, status),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusAction(String psychiatristId, String? status) {
    if (_isLoadingRelations) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: const SnakeLoadingIndicator(),
      );
    }

    if (status == 'accepted') {
      return _StatusChip(label: 'Connected', color: const Color(0xFF2F9E6F));
    }
    if (status == 'pending') {
      return _StatusChip(label: 'Pending', color: const Color(0xFFB5832B));
    }

    return TextButton(
      onPressed: () => _handleSendRequest(psychiatristId),
      child: const Text('Request'),
    );
  }

  Future<void> _handleSendRequest(String psychiatristId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    final error = await _service.sendRequest(
      userId: user.uid,
      psychiatristId: psychiatristId,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    await _loadRelationshipStatus();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent.')),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
