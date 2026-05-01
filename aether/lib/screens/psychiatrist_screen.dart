import 'dart:ui' show ImageFilter;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/patient_link.dart';
import '../models/patient_request.dart';
import '../services/psychiatrist_service.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_flow_loader.dart';
import 'login_screen.dart';
import 'patient_detail_screen.dart';

class PsychiatristScreen extends StatefulWidget {
  const PsychiatristScreen({super.key});

  @override
  State<PsychiatristScreen> createState() => _PsychiatristScreenState();
}

class _PsychiatristScreenState extends State<PsychiatristScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PsychiatristService _service = PsychiatristService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _psychiatristId;
  bool _isVerified = false;
  bool _isLoadingProfile = true;
  String _displayName = 'Psychiatrist';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _psychiatristId = _service.getCurrentUserId();
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    if (!mounted) {
      return;
    }

    final rawName = data != null ? data['name'] : null;
    final rawEmail = data != null ? data['email'] : null;

    setState(() {
      _isVerified = data != null && data['is_verified'] == true;
      _displayName = (rawName is String && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'Psychiatrist');
      _email = (rawEmail is String && rawEmail.trim().isNotEmpty)
        ? rawEmail.trim()
        : (user.email ?? '');
      _isLoadingProfile = false;
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
        title: const Text(''),
      ),
      body: Stack(
        children: [
          const _SoftBackground(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _DashboardHeader(
                  name: _displayName,
                  email: _email,
                  isVerified: _isVerified,
                  isLoading: _isLoadingProfile,
                  onSignOut: () async {
                    await runWithAuthFlowLoader<void>(
                      context: context,
                      message: 'Signing you out...',
                      action: () => FirebaseAuth.instance.signOut(),
                    );
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: StreamBuilder<List<PatientLink>>(
                  stream: _service.getPatients(_psychiatristId ?? ''),
                  builder: (context, patientSnapshot) {
                    final patientCount = patientSnapshot.data?.length ?? 0;
                    return StreamBuilder<List<PatientRequest>>(
                      stream: _service.getPendingRequests(_psychiatristId ?? ''),
                      builder: (context, requestSnapshot) {
                        final requestCount = requestSnapshot.data?.length ?? 0;
                        return Row(
                          children: [
                            Expanded(
                              child: _StatPill(
                                label: 'Patients',
                                value: patientCount,
                                icon: Icons.folder_shared_rounded,
                                accent: const Color(0xFF2F9E6F),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatPill(
                                label: 'Requests',
                                value: requestCount,
                                icon: Icons.mark_email_unread_rounded,
                                accent: const Color(0xFF3A6EA5),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _TabPillBar(controller: _tabController),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPatientsTab(context),
                    _buildRequestsTab(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab(BuildContext context) {
    final psychiatristId = _psychiatristId;
    if (psychiatristId == null) {
      return _buildEmptyState('Sign in to view your patients.');
    }

    return Column(
      children: [
        if (!_isLoadingProfile && !_isVerified)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppCard(
              color: const Color(0xFFFFF5E5),
              child: Row(
                children: const [
                  Icon(Icons.verified_outlined, color: Color(0xFFB57300)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your account is awaiting verification. Patients will be visible once approved.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A4D00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: StreamBuilder<List<PatientLink>>(
            stream: _service.getPatients(psychiatristId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: const SnakeLoadingIndicator());
              }

              final patients = snapshot.data ?? <PatientLink>[];
              if (patients.isEmpty) {
                return _buildEmptyState('No accepted patients yet.');
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: patients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE8F4F1),
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F9E6F).withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF3AA891).withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(22),
                          bottomLeft: Radius.circular(22),
                          bottomRight: Radius.circular(22),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PatientDetailScreen(
                                userId: patient.userId,
                                userName: patient.userName,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.folder_open_rounded,
                                  color: Color(0xFF3AA891),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.userName,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E3A45),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Open patient folder',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5F7380),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF8DA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab(BuildContext context) {
    final psychiatristId = _psychiatristId;
    if (psychiatristId == null) {
      return _buildEmptyState('Sign in to view requests.');
    }

    return StreamBuilder<List<PatientRequest>>(
      stream: _service.getPendingRequests(psychiatristId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: const SnakeLoadingIndicator());
        }

        final requests = snapshot.data ?? <PatientRequest>[];
        if (requests.isEmpty) {
          return _buildEmptyState('No pending requests right now.');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF2F7FD), Colors.white],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A6EA5).withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF3A6EA5).withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: _RequestTile(
                request: request,
                firestore: _firestore,
                onAccept: () => _handleAccept(request.id),
                onReject: () => _handleReject(request.id),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAccept(String requestId) async {
    await _service.acceptRequest(requestId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request accepted.')),
    );
  }

  Future<void> _handleReject(String requestId) async {
    await _service.rejectRequest(requestId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request rejected.')),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.name,
    required this.email,
    required this.isVerified,
    required this.isLoading,
    required this.onSignOut,
  });

  final String name;
  final String email;
  final bool isVerified;
  final bool isLoading;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final greeting = _formatDoctorGreeting(name);
    final statusLabel = isLoading
        ? 'Checking verification...'
        : isVerified
            ? 'Verified psychiatrist'
            : 'Verification pending';
    final statusColor = isVerified ? const Color(0xFF2F9E6F) : const Color(0xFFB5832B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A45),
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email.isEmpty ? 'Signed in' : email,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F7380),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        _ProfileMenuButton(onSignOut: onSignOut),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.firestore,
    required this.onAccept,
    required this.onReject,
  });

  final PatientRequest request;
  final FirebaseFirestore firestore;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: firestore.collection('users').doc(request.userId).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = data?['name'] as String? ?? 'Unknown user';
        final email = data?['email'] as String? ?? 'No email';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF3AA891),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5F7380),
                        ),
                      ),
                    ],
                  ),
                ),
                _ActionPill(
                  label: 'Reject',
                  color: const Color(0xFFD36B6B),
                  onTap: onReject,
                ),
                const SizedBox(width: 8),
                _ActionPill(
                  label: 'Accept',
                  color: const Color(0xFF2F9E6F),
                  onTap: onAccept,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FBFA),
              Color(0xFFF3F7F5),
              Color(0xFFEAF3EF),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPillBar extends StatelessWidget {
  const _TabPillBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppShadows.soft],
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: const Color(0xFF2F9E6F).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: const Color(0xFF1E3A45),
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Patients'),
          Tab(text: 'Requests'),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withOpacity(0.12), Colors.white],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(label, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.16),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDoctorGreeting(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'Hi Dr. there';
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('dr.')) {
    return 'Hi $trimmed';
  }
  return 'Hi Dr. $trimmed';
}

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.82),
                    Colors.white.withOpacity(0.46),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.68),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C333B).withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _showSignOutDialog(context),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2FB07E),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Poppins')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2FB07E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
