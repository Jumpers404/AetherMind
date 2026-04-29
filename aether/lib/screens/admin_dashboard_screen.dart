import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      backgroundColor: AppColors.background,
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
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminHeader(onSignOut: handleSignOut),
                    const SizedBox(height: AppSpacing.md),
                    _SectionBlock(
                      title: 'System Overview',
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
                    const SizedBox(height: AppSpacing.lg),
                    _SectionBlock(
                      title: 'User Management',
                      subtitle: 'Roles, verification, and access control',
                      child: users.isEmpty
                          ? const _EmptySectionCard(message: 'No users found.')
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: users.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    const SizedBox(height: AppSpacing.lg),
                    _SectionBlock(
                      title: 'All Journals',
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
                    const SizedBox(height: AppSpacing.lg),
                    _SectionBlock(
                      title: 'Patient Relationships',
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
                    const SizedBox(height: AppSpacing.lg),
                    _SectionBlock(
                      title: 'All Requests',
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
                  ],
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
        title: const Text('Delete user?'),
        content: const Text(
          'This removes the user record from Firestore. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD36B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Center',
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A45),
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage users & system',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F7380),
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
      childAspectRatio: 1.2,
      children: [
        _StatCard(
          title: 'Total Users',
          value: totalUsers,
          icon: Icons.people_alt_rounded,
          gradient: const [Color(0xFF80CBC4), Color(0xFFB2DFDB)],
          iconColor: const Color(0xFF26665D),
        ),
        _StatCard(
          title: 'Psychiatrists',
          value: totalPsychiatrists,
          icon: Icons.medical_services_rounded,
          gradient: const [Color(0xFF8FD3C9), Color(0xFFCFEDE8)],
          iconColor: const Color(0xFF2D726B),
        ),
        _StatCard(
          title: 'Verified',
          value: verifiedPsychiatrists,
          icon: Icons.verified_rounded,
          gradient: const [Color(0xFF81C784), Color(0xFFA5D6A7)],
          iconColor: const Color(0xFF2B8C43),
        ),
        _StatCard(
          title: 'Journals',
          value: totalJournals,
          icon: Icons.menu_book_rounded,
          gradient: const [Color(0xFFB1BCCF), Color(0xFFC7D0E0)],
          iconColor: const Color(0xFF4B566E),
        ),
        _StatCard(
          title: 'Active Patients',
          value: activePatients,
          icon: Icons.folder_shared_rounded,
          gradient: const [Color(0xFFE88A58), Color(0xFFF0AA82)],
          iconColor: const Color(0xFFC1662F),
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
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF4FBF8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          child,
        ],
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
    required this.iconColor,
  });

  final String title;
  final int value;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.25),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
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
          style: const TextStyle(
            fontFamily: 'Doto',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodySecondary),
      ],
    );
  }
}


class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(message, style: AppTextStyles.bodySecondary),
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

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(role);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, roleColor.withOpacity(0.05)],
        ),
        boxShadow: [
          BoxShadow(
            color: roleColor.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: roleColor.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: roleColor,
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
                        fontSize: 15,
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
              _RolePill(role: role, color: roleColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _RoleSelector(
                      currentRole: role,
                      onChanged: onRoleChanged,
                    ),
                    if (role == 'psychiatrist')
                      _VerificationPill(
                        isVerified: isVerified,
                        onChanged: onVerificationChanged,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentRole,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
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
    final bgColor = isVerified
        ? const Color(0xFF2F9E6F)
        : const Color(0xFFB5832B);
    return InkWell(
      onTap: () => onChanged(!isVerified),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified_rounded : Icons.verified_outlined,
              size: 16,
              color: bgColor,
            ),
            const SizedBox(width: 6),
            Text(
              isVerified ? 'Verified' : 'Verify',
              style: TextStyle(
                color: bgColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD36B6B).withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFD36B6B),
          size: 18,
        ),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203D48).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8F1EC),
          width: 1.2,
        ),
      ),
      child: Column(
        children: journals.map((journal) {
          final userId = journal['user_id'] as String? ?? '';
          final userName = _resolveUserName(userMap, userId);
          final emotion = journal['emotion'] as String? ?? 'unknown';
          final timestamp = _formatTimestamp(journal['timestamp']);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DotAvatar(color: const Color(0xFF2F9E6F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Emotion: $emotion',
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
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8DA3AF),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RelationshipListCard extends StatelessWidget {
  const _RelationshipListCard({
    required this.patients,
    required this.userMap,
  });

  final List<Map<String, dynamic>> patients;
  final Map<String, Map<String, dynamic>> userMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203D48).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8F1EC),
          width: 1.2,
        ),
      ),
      child: Column(
        children: patients.map((patient) {
          final userId = patient['user_id'] as String? ?? '';
          final psychiatristId = patient['psychiatrist_id'] as String? ?? '';
          final userName = _resolveUserName(userMap, userId);
          final psychiatristName = _resolveUserName(userMap, psychiatristId);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _DotAvatar(color: const Color(0xFF3BB08F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$userName <-> $psychiatristName',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A45),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RequestListCard extends StatelessWidget {
  const _RequestListCard({required this.requests, required this.userMap});

  final List<Map<String, dynamic>> requests;
  final Map<String, Map<String, dynamic>> userMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203D48).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8F1EC),
          width: 1.2,
        ),
      ),
      child: Column(
        children: requests.map((request) {
          final userId = request['user_id'] as String? ?? '';
          final psychiatristId = request['psychiatrist_id'] as String? ?? '';
          final status = request['status'] as String? ?? 'pending';
          final userName = _resolveUserName(userMap, userId);
          final psychiatristName = _resolveUserName(userMap, psychiatristId);
          final statusColor = _statusColor(status);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DotAvatar(color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$userName <-> $psychiatristName',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DotAvatar extends StatelessWidget {
  const _DotAvatar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

Color _roleColor(String role) {
  switch (role) {
    case 'psychiatrist':
      return const Color(0xFF2F9E6F);
    case 'admin':
      return const Color(0xFF7A67C7);
    default:
      return const Color(0xFF7A7A7A);
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return const Color(0xFF2F9E6F);
    case 'rejected':
      return const Color(0xFFD36B6B);
    default:
      return const Color(0xFFB5832B);
  }
}

String _resolveUserName(
  Map<String, Map<String, dynamic>> userMap,
  String userId,
) {
  final data = userMap[userId];
  return data?['name'] as String? ?? 'Unknown';
}

String _formatTimestamp(dynamic value) {
  if (value == null) {
    return 'Unknown time';
  }
  if (value is Timestamp) {
    final date = value.toDate();
    return _formatDate(date);
  }
  if (value is DateTime) {
    return _formatDate(value);
  }
  if (value is int) {
    return _formatDate(DateTime.fromMillisecondsSinceEpoch(value));
  }
  return 'Unknown time';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
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

