import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:aether/widgets/auth_flow_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/onboarding_service.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

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
      if (mounted) {
        setState(() {
          _profileData = data;
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
        body: Center(child: const SnakeLoadingIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7FBF9), Color(0xFFF3F7F5), Color(0xFFEAF3EF)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIdentityHeader(),
                        const SizedBox(height: 32),
                        _buildIdentitySummary(),
                        const SizedBox(height: 28),
                        _buildInterestEcosystem(),
                        const SizedBox(height: 32),
                        _buildPersonalityMix(),
                        const SizedBox(height: 32),
                        _buildComfortToolkit(),
                        const SizedBox(height: 48),
                        _buildSignOutAction(),
                        const SizedBox(height: 54),
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
            'IDENTITY',
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: 15,
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

  Widget _buildIdentityHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "Explorer";
    final username = "@${(user?.email ?? 'user').split('@').first.toLowerCase()}";
    
    final rawInterests = List<String>.from(_profileData?['interests'] ?? []);
    final rawActivities = List<String>.from(_profileData?['preferences']?['activities'] ?? []);
    
    String tagline = "Balance • Growth • Awareness";
    if (rawInterests.isNotEmpty || rawActivities.isNotEmpty) {
      final parts = [...rawInterests, ...rawActivities].map((e) => _sanitize(e)).toList();
      if (parts.length >= 2) {
        tagline = "${parts[0]} • ${parts[1]}${parts.length > 2 ? ' • ' + parts[2] : ''}";
      } else if (parts.isNotEmpty) {
        tagline = parts[0];
      }
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0, 0.5)),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0EBE6), width: 1.5),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6EC6B3), Color(0xFF4DA692)],
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 52),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E3C44),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                username,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2FB07E),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EC6B3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.2)),
                ),
                child: Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4DA692),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem("0", "Followers"),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    width: 1,
                    height: 14,
                    color: const Color(0xFFE0EBE6),
                  ),
                  _buildStatItem("0", "Following"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$count ",
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E3C44),
              fontSize: 14,
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

  Widget _buildIdentitySummary() {
    final methods = List<String>.from(_profileData?['relief_methods'] ?? []).map((e) => _sanitize(e)).toList();
    final prefMusic = List<String>.from(_profileData?['preferences']?['music'] ?? []).map((e) => _sanitize(e)).toList();
    
    String summary = "You appreciate immersive experiences and tend to find clarity through quiet observation and consistent growth.";
    if (methods.isNotEmpty && prefMusic.isNotEmpty) {
      summary = "Personalized journey powered by ${methods[0].toLowerCase()} and a deep appreciation for ${prefMusic[0].toLowerCase()} and mindful living.";
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0.2, 0.6)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bubble_chart_rounded, size: 16, color: Color(0xFF2FB07E)),
                const SizedBox(width: 8),
                Text(
                  "IDENTITY SUMMARY",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF2FB07E).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              summary,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3C44).withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestEcosystem() {
    final interests = List<String>.from(_profileData?['interests'] ?? []).map((e) => _sanitize(e)).toList();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0.3, 0.7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSleekTitle("CORE INTERESTS"),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...interests.map((i) => _InterestPill(label: i)),
              _AddInterestButton(onTap: _showAddInterestDialog),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityMix() {
    final preferences = _profileData?['preferences'] as Map<String, dynamic>?;
    final music = List<String>.from(preferences?['music'] ?? []).map((e) => _sanitize(e)).toList();
    final movies = List<String>.from(preferences?['movies'] ?? []).map((e) => _sanitize(e)).toList();
    
    if (music.isEmpty && movies.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0.4, 0.8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSleekTitle("PERSONALITY MIX"),
          const SizedBox(height: 18),
          if (music.isNotEmpty) ...[
            _PreferenceSection(icon: Icons.headphones_rounded, title: "Sonic Selection", items: music, filled: true),
            const SizedBox(height: 16),
          ],
          if (movies.isNotEmpty) ...[
            _PreferenceSection(icon: Icons.videocam_rounded, title: "Visual Preference", items: movies, filled: false),
          ],
        ],
      ),
    );
  }

  Widget _buildComfortToolkit() {
    final methods = List<String>.from(_profileData?['relief_methods'] ?? []).map((e) => _sanitize(e)).toList();
    if (methods.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0.5, 0.9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSleekTitle("COMFORT TOOLKIT"),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: methods.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              return _ComfortCapsule(text: text, isOdd: idx % 2 != 0);
            }).toList(),
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

  Widget _buildSignOutAction() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _revealController, curve: const Interval(0.8, 1.0)),
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
}

class _InterestPill extends StatelessWidget {
  final String label;
  const _InterestPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F7),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.3), width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E3C44),
        ),
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

class _ComfortCapsule extends StatelessWidget {
  final String text;
  final bool isOdd;
  
  const _ComfortCapsule({required this.text, required this.isOdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isOdd ? 24 : 18, 
        vertical: isOdd ? 14 : 12
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOdd 
            ? [const Color(0xFFF0F9F7), const Color(0xFFFDFDFD)] 
            : [Colors.white, const Color(0xFFF7FBF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isOdd ? 24 : 32),
        border: Border.all(
          color: const Color(0xFF6EC6B3).withValues(alpha: isOdd ? 0.3 : 0.1), 
          width: 1.5
        ),
        boxShadow: const [AppShadows.soft],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E3C44).withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
