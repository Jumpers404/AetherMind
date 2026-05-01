import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/onboarding_service.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import '../services/insight_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onSignOut;

  const ProfileScreen({Key? key, this.onSignOut}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final OnboardingService _onboardingService = OnboardingService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  late AnimationController _revealController;
  final TextEditingController _bioController = TextEditingController();
  bool _isEditingBio = false;
  int _streak = 0;
  int _moodChecksCount = 0;
  int _insightsCount = 0;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchProfile();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _onboardingService.getOnboardingProfile();
      final journals = await JournalService().getUserJournals();

      int streak = _calculateStreak(journals);
      int moodChecks = journals.length;
      int insights = 0;
      if (journals.isNotEmpty) {
        try {
          insights = InsightService().generateClinicalInsights(journals).keys.length;
        } catch (_) {
          insights = 5;
        }
      }

      if (mounted) {
        setState(() {
          _profileData = data;
          _bioController.text = data?['bio'] ?? "Click to add a bio about your journey...";
          _streak = streak;
          _moodChecksCount = moodChecks;
          _insightsCount = insights;
          _isLoading = false;
        });
        _revealController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateStreak(List<JournalEntry> journals) {
    if (journals.isEmpty) return 0;
    
    // Get unique dates sorted descending
    final dates = journals
        .map((j) => DateTime(j.timestamp.year, j.timestamp.month, j.timestamp.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first == today) {
      streak = 1;
      for (int i = 1; i < dates.length; i++) {
        if (dates[i] == today.subtract(Duration(days: i))) {
          streak++;
        } else {
          break;
        }
      }
    } else if (dates.first == yesterday) {
      streak = 1;
      for (int i = 1; i < dates.length; i++) {
        if (dates[i] == yesterday.subtract(Duration(days: i))) {
          streak++;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  Future<void> _saveBio() async {
    final newBio = _bioController.text.trim();
    setState(() {
      _profileData?['bio'] = newBio;
      _isEditingBio = false;
    });
    await _onboardingService.updateBio(newBio);
  }

  Future<void> _addInterest(String interest) async {
    if (interest.isEmpty) return;
    
    final currentInterests = List<String>.from(_profileData?['interests'] ?? []);
    if (!currentInterests.contains(interest)) {
      currentInterests.add(interest);
      
      setState(() {
        _profileData?['interests'] = currentInterests;
      });

      await _onboardingService.updateInterests(currentInterests);
    }
  }

  String _sanitize(String text) {
    return text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F3FB}-\u{1F3FF}\u{200D}\u{FE0F}]', unicode: true), '').trim();
  }

  void _showAddInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7FBF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'EXPLORE NEW INTEREST',
          style: TextStyle(
            fontFamily: 'Doto',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
            color: const Color(0xFF1E3C44),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Music, Tech, Nature...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0EBE6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0EBE6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6EC6B3), width: 1.5),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              _addInterest(controller.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6EC6B3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('ADD', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FBF9),
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEAF3EF),
                    Color(0xFFF3F7F5),
                    Color(0xFFF7FBF9),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Decorative Abstract Blobs (Non-pixelated)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6EC6B3).withValues(alpha: 0.1),
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
                color: const Color(0xFF2D726B).withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIdentitySection(),
                              const SizedBox(height: 24),
                              _buildStatsRow(),
                              const SizedBox(height: 32),
                              _buildGlassSection(
                                title: "CORE INTERESTS",
                                child: _buildInterestEcosystem(),
                                onEdit: () => _showAddInterestDialog(),
                              ),
                              const SizedBox(height: 24),
                              _buildGlassSection(
                                title: "PERSONALITY MIX",
                                child: _buildPersonalityMix(),
                                onEdit: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Edit functionality coming soon!',
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      backgroundColor: const Color(0xFF2D726B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                              _buildSignOutAction(),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E3C44), size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'PROFILE',
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: const Color(0xFF1E3C44).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGlassSection({required String title, required Widget child, VoidCallback? onEdit}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSleekTitle(title),
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF4DA692)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D726B), Color(0xFF6EC6B3), Color(0xFFB8D3CC)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.spa_rounded,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
          // Profile Image (Overlapping)
          Positioned(
            bottom: 0,
            left: 22,
            child: Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6EC6B3), Color(0xFF4DA692)],
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 60),
              ),
            ),
          ),
          // Edit Profile Button (Parallel to avatar)
          Positioned(
            bottom: 12,
            right: 22,
            child: _GhostEditButton(
              onTap: () => setState(() => _isEditingBio = !_isEditingBio),
              isEditing: _isEditingBio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "Explorer";
    final username = "@${(user?.email ?? 'user').split('@').first.toLowerCase()}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E3C44),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          username,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2FB07E),
          ),
        ),
        const SizedBox(height: 12),
        // Social Stats Row
        Row(
          children: [
            _buildMiniSocialStat("${_profileData?['followers'] ?? 0}", "Followers"),
            _buildSocialDivider(),
            _buildMiniSocialStat("${_profileData?['following'] ?? 0}", "Following"),
            _buildSocialDivider(),
            Row(
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFF2FB07E), size: 14),
                const SizedBox(width: 4),
                _buildMiniSocialStat("${_profileData?['hearts'] ?? 0}", "Hearts"),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _isEditingBio
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1E3C44),
                    ),
                    decoration: InputDecoration(
                      hintText: "Share your journey...",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0EBE6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveBio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D726B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Save Bio', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingBio = true),
                child: Text(
                  _bioController.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E3C44).withValues(alpha: 0.7),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildMiniSocialStat(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$count ",
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E3C44),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF5F7380),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 1,
      height: 12,
      color: const Color(0xFFE0EBE6),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildCompactStat("$_streak", "Days Streak"),
        const SizedBox(width: 12),
        _buildCompactStat("$_moodChecksCount", "Journal Count"),
        const SizedBox(width: 12),
        _buildCompactStat("$_insightsCount", "Insights"),
      ],
    );
  }

  Widget _buildCompactStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0EBE6)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Doto',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E3C44),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2FB07E),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestEcosystem() {
    final interests = List<String>.from(_profileData?['interests'] ?? []).map((e) => _sanitize(e)).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...interests.map((i) => _InterestPill(label: i)),
        _AddInterestButton(onTap: _showAddInterestDialog),
      ],
    );
  }

  Widget _buildPersonalityMix() {
    final preferences = _profileData?['preferences'] as Map<String, dynamic>?;
    final music = List<String>.from(preferences?['music'] ?? []).map((e) => _sanitize(e)).toList();
    final movies = List<String>.from(preferences?['movies'] ?? []).map((e) => _sanitize(e)).toList();
    
    if (music.isEmpty && movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (music.isNotEmpty) ...[
          _PreferenceSection(icon: Icons.headphones_rounded, title: "Sonic Selection", items: music, filled: true),
          const SizedBox(height: 16),
        ],
        if (movies.isNotEmpty) ...[
          _PreferenceSection(icon: Icons.videocam_rounded, title: "Visual Preference", items: movies, filled: false),
        ],
      ],
    );
  }

  Widget _buildSignOutAction() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 1,
            width: 40,
            color: const Color(0xFFE0EBE6),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onSignOut,
            style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
            child: Text(
              "Sign Out Account",
              style: GoogleFonts.poppins(
                color: const Color(0xFFE53935).withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Doto',
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
        color: const Color(0xFF1E3C44).withValues(alpha: 0.5),
      ),
    );
  }
}

class _GhostEditButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEditing;

  const _GhostEditButton({required this.onTap, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0EBE6)),
          color: isEditing ? const Color(0xFF2D726B).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditing ? Icons.close : Icons.edit_note_rounded,
              size: 18,
              color: const Color(0xFF2D726B),
            ),
            const SizedBox(width: 6),
            Text(
              isEditing ? 'Cancel' : 'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D726B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestPill extends StatelessWidget {
  final String label;
  const _InterestPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6EC6B3).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF2FB07E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3C44),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddInterestButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddInterestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFE0EBE6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFF4DA692), size: 24),
      ),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final bool filled;

  const _PreferenceSection({
    required this.icon,
    required this.title,
    required this.items,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFF6EC6B3).withValues(alpha: 0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF4DA692)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E3C44).withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((i) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: filled ? const Color(0xFF6EC6B3).withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0EBE6)),
                  ),
                  child: Text(
                    i,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3C44),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
