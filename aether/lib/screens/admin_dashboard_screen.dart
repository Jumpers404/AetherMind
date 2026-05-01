import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../services/admin_service.dart';
import '../widgets/app_card.dart';
import '../widgets/auth_flow_loader.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(''),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: adminService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? <Map<String, dynamic>>[];
          final userMap = <String, Map<String, dynamic>>{
            for (final user in users)
              if ((user['id'] as String?) != null) user['id'] as String: user,
          };
          final psychiatristCount = users
              .where((user) => user['role'] == 'psychiatrist')
              .length;
          final verifiedCount = users
              .where((user) =>
                  user['role'] == 'psychiatrist' && user['is_verified'] == true)
              .length;

          void handleSignOut() async {
            await runWithAuthFlowLoader<void>(
              context: context,
              message: 'Signing you out...',
              action: () => FirebaseAuth.instance.signOut(),
            );
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }

          return Stack(
            children: [
              const _SoftBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AdminHeader(onSignOut: handleSignOut),
                      const SizedBox(height: 24),
                      _SectionBlock(
                        title: 'SYSTEM OVERVIEW',
                        subtitle: 'Live stats across the platform',
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: adminService.getAllJournals(),
                          builder: (context, journalSnapshot) {
                            final journals = journalSnapshot.data ?? <Map<String, dynamic>>[];
                            return StreamBuilder<List<Map<String, dynamic>>>(
                              stream: adminService.getAllPatientLinks(),
                              builder: (context, patientSnapshot) {
                                final patients = patientSnapshot.data ?? <Map<String, dynamic>>[];
                                return _StatsGrid(
                                  totalUsers: users.length,
                                  totalPsychiatrists: psychiatristCount,
                                  verifiedPsychiatrists: verifiedCount,
                                  totalJournals: journals.length,
                                  activePatients: patients.length,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SectionBlock(
                        title: 'USER MANAGEMENT',
                        subtitle: 'Roles, verification, and access control',
                        child: users.isEmpty
                            ? const _EmptySectionCard(message: 'No users found.')
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: users.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  final userId = user['id'] as String? ?? '';
                                  final name = user['name'] as String? ?? 'Unknown';
                                  final email = user['email'] as String? ?? '';
                                  final role = user['role'] as String? ?? 'user';
                                  final isVerified = user['is_verified'] == true;

                                  return _UserManagementCard(
                                    userId: userId,
                                    name: name,
                                    email: email,
                                    role: role,
                                    isVerified: isVerified,
                                    onRoleChanged: (value) {
                                      if (value != null && value != role) {
                                        adminService.updateUserRole(userId, value);
                                      }
                                    },
                                    onVerificationChanged: (value) {
                                      adminService.toggleVerification(userId, value);
                                    },
                                    onDelete: () => _confirmDelete(context, () async {
                                      await adminService.deleteUser(userId);
                                    }),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 32),
                      _SectionBlock(
                        title: 'ALL JOURNALS',
                        subtitle: 'Latest user reflections with emotion tags',
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: adminService.getAllJournals(),
                          builder: (context, journalSnapshot) {
                            final journals = journalSnapshot.data ?? <Map<String, dynamic>>[];
                            if (journals.isEmpty) {
                              return const _EmptySectionCard(
                                message: 'No journal entries found.',
                              );
                            }
                            return _JournalListCard(
                              journals: journals.take(10).toList(),
                              userMap: userMap,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SectionBlock(
                        title: 'PATIENT RELATIONSHIPS',
                        subtitle: 'User to psychiatrist mappings',
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: adminService.getAllPatientLinks(),
                          builder: (context, patientSnapshot) {
                            final patients = patientSnapshot.data ?? <Map<String, dynamic>>[];
                            if (patients.isEmpty) {
                              return const _EmptySectionCard(
                                message: 'No patient relationships yet.',
                              );
                            }
                            return _RelationshipListCard(
                              patients: patients.take(10).toList(),
                              userMap: userMap,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SectionBlock(
                        title: 'ALL REQUESTS',
                        subtitle: 'Pending, accepted, and rejected requests',
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: adminService.getAllRequests(),
                          builder: (context, requestSnapshot) {
                            final requests = requestSnapshot.data ?? <Map<String, dynamic>>[];
                            if (requests.isEmpty) {
                              return const _EmptySectionCard(message: 'No requests found.');
                            }
                            return _RequestListCard(
                              requests: requests.take(12).toList(),
                              userMap: userMap,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Future<void> Function() onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7FBF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'DELETE USER?',
          style: TextStyle(
            fontFamily: 'Doto',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
            color: const Color(0xFF1E3C44),
          ),
        ),
        content: Text(
          'This removes the user record from Firestore. This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF5F7380)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD36B6B).withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('DELETE', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Center',
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E3C44),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Identity & System Orchestration',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5F7380).withValues(alpha: 0.7),
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

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7FBF9),
              Color(0xFFF3F7F5),
              Color(0xFFEAF3EF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6EC6B3).withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2FB07E).withValues(alpha: 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalUsers,
    required this.totalPsychiatrists,
    required this.verifiedPsychiatrists,
    required this.totalJournals,
    required this.activePatients,
  });

  final int totalUsers;
  final int totalPsychiatrists;
  final int verifiedPsychiatrists;
  final int totalJournals;
  final int activePatients;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        _StatCard(
          title: 'Total Users',
          value: totalUsers,
          icon: Icons.people_alt_rounded,
          gradient: const [Color(0xFF6EC6B3), Color(0xFF4DA692)],
        ),
        _StatCard(
          title: 'Psychiatrists',
          value: totalPsychiatrists,
          icon: Icons.medical_services_rounded,
          gradient: const [Color(0xFF2FB07E), Color(0xFF269E70)],
        ),
        _StatCard(
          title: 'Verified Docs',
          value: verifiedPsychiatrists,
          icon: Icons.verified_user_rounded,
          gradient: const [Color(0xFF4DB6AC), Color(0xFF009688)],
        ),
        _StatCard(
          title: 'Journal Reflections',
          value: totalJournals,
          icon: Icons.menu_book_rounded,
          gradient: const [Color(0xFF546E7A), Color(0xFF37474F)],
        ),
        _StatCard(
          title: 'Care Links',
          value: activePatients,
          icon: Icons.share_location_rounded,
          gradient: const [Color(0xFFFF8A65), Color(0xFFE64A19)],
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: title, subtitle: subtitle),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final int value;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: const Color(0xFF1E3C44),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5F7380).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5F7380),
        ),
      ),
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  const _UserManagementCard({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.onRoleChanged,
    required this.onVerificationChanged,
    required this.onDelete,
  });

  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<bool> onVerificationChanged;
  final VoidCallback onDelete;

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFF546E7A);
      case 'psychiatrist': return const Color(0xFF2FB07E);
      default: return const Color(0xFF4DA692);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(role);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_rounded, color: roleColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3C44),
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5F7380),
                      ),
                    ),
                  ],
                ),
              ),
              _RolePill(role: role, color: roleColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _RoleSelector(currentRole: role, onChanged: onRoleChanged),
              const SizedBox(width: 10),
              if (role == 'psychiatrist')
                _VerificationPill(isVerified: isVerified, onChanged: onVerificationChanged),
              const Spacer(),
              _DeleteIconButton(onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.currentRole, required this.onChanged});

  final String currentRole;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => onChanged(value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'user', child: Text('User')),
        PopupMenuItem(value: 'psychiatrist', child: Text('Psychiatrist')),
        PopupMenuItem(value: 'admin', child: Text('Admin')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0EBE6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentRole.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
          ],
        ),
      ),
    );
  }
}

class _VerificationPill extends StatelessWidget {
  const _VerificationPill({required this.isVerified, required this.onChanged});

  final bool isVerified;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? const Color(0xFF2FB07E) : const Color(0xFFFFB74D);
    return InkWell(
      onTap: () => onChanged(!isVerified),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              isVerified ? 'VERIFIED' : 'PENDING',
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteIconButton extends StatelessWidget {
  const _DeleteIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD36B6B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD36B6B), size: 20),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role, required this.color});

  final String role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }
}

class _JournalListCard extends StatelessWidget {
  const _JournalListCard({required this.journals, required this.userMap});

  final List<Map<String, dynamic>> journals;
  final Map<String, Map<String, dynamic>> userMap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: journals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final journal = journals[index];
        final userId = journal['user_id'] as String? ?? '';
        final userName = userMap[userId]?['name'] as String? ?? 'Unknown';
        final text = journal['text'] as String? ?? '';
        final emotion = journal['emotion'] as String? ?? '';
        
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E3C44)),
                  ),
                  if (emotion.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EC6B3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emotion,
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF2FB07E)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5F7380), height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelationshipListCard extends StatelessWidget {
  const _RelationshipListCard({required this.patients, required this.userMap});

  final List<Map<String, dynamic>> patients;
  final Map<String, Map<String, dynamic>> userMap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rel = patients[index];
        final patientId = rel['user_id'] as String? ?? '';
        final psychId = rel['psychiatrist_id'] as String? ?? '';
        final pName = userMap[patientId]?['name'] as String? ?? 'Unknown';
        final psName = userMap[psychId]?['name'] as String? ?? 'Unknown';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, color: Color(0xFF6EC6B3), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$pName connected to Dr. $psName",
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E3C44)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestListCard extends StatelessWidget {
  const _RequestListCard({required this.requests, required this.userMap});

  final List<Map<String, dynamic>> requests;
  final Map<String, Map<String, dynamic>> userMap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requests[index];
        final senderId = req['user_id'] as String? ?? '';
        final receiverId = req['psychiatrist_id'] as String? ?? '';
        final status = req['status'] as String? ?? '';
        final sName = userMap[senderId]?['name'] as String? ?? 'Unknown';
        final rName = userMap[receiverId]?['name'] as String? ?? 'Unknown';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.outbox_rounded, color: Color(0xFF6EC6B3), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$sName ➔ $rName",
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E3C44)),
                    ),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF2FB07E), letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'sign_out') {
          onSignOut();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'sign_out',
          child: Text('Sign Out'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0EBE6)),
        ),
        child: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFD36B6B), size: 20),
      ),
    );
  }
}
