import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/onboarding_service.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import '../services/insight_service.dart';
import '../widgets/auth_flow_loader.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onSignOut;

  const ProfileScreen({super.key, this.onSignOut});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final OnboardingService _onboardingService = OnboardingService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  late AnimationController _revealController;
  late AnimationController _gradientController;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditingBio = false;
  int _streak = 0;
  int _moodChecksCount = 0;
  int _insightsCount = 0;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchProfile();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _revealController.dispose();
    _bioController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final defaultUsername = (user?.email ?? 'user').split('@').first.toLowerCase();
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
          _bioController.text = data?['bio'] ?? "";
          _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? "Explorer";
          _usernameController.text = (data?['username'] ?? defaultUsername).toString().replaceAll('@', '');
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
    final newName = _nameController.text.trim();
    final rawUsername = _usernameController.text.trim();
    final newUsername = rawUsername.startsWith('@') ? rawUsername.substring(1) : rawUsername;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && newName.isNotEmpty && newName != user.displayName) {
      await user.updateDisplayName(newName);
    }

    setState(() {
      _profileData?['bio'] = newBio;
      if (newUsername.isNotEmpty) {
        _profileData?['username'] = newUsername;
        _usernameController.text = newUsername;
      }
      _isEditingBio = false;
    });
    await _onboardingService.updateBio(newBio);
    if (newUsername.isNotEmpty) {
      await _onboardingService.updateUsername(newUsername);
    }
  }

  Future<void> _regenerateAvatar(String gender) async {
    final newSeed = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _profileData?['avatar_seed'] = newSeed;
      _profileData?['gender'] = gender;
    });
    await _onboardingService.updateAvatarParams(newSeed, gender);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF7FBF9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'EXPLORE NEW INTEREST',
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: const Color(0xFF1E3C44),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Music, Tech, Nature...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    borderSide: const BorderSide(color: Color(0xFF6EC6B3), width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _addInterest(controller.text);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4D9489), Color(0xFF3B7F75)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x243B7F75),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'ADD INTEREST',
                        style: TextStyle(
                          fontFamily: 'Doto',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: const Color(0xFFE8F4F1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showAvatarGenderSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FBF9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SELECT GENDER',
              style: TextStyle(
                fontFamily: 'Doto',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
                color: const Color(0xFF1E3C44),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    title: 'Male',
                    icon: Icons.male_rounded,
                    onTap: () {
                      _regenerateAvatar('Male');
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderOption(
                    title: 'Female',
                    icon: Icons.female_rounded,
                    onTap: () {
                      _regenerateAvatar('Female');
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption({required String title, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0EBE6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF6EC6B3)),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: const Color(0xFF1E3C44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPreference(String key, String item) async {
    if (item.isEmpty) return;
    
    final preferences = Map<String, dynamic>.from(_profileData?['preferences'] ?? {});
    final List<String> currentList = List<String>.from(preferences[key] ?? []);
    if (!currentList.contains(item)) {
      currentList.add(item);
      preferences[key] = currentList;
      
      setState(() {
        _profileData?['preferences'] = preferences;
      });

      await _onboardingService.updatePreferences(preferences);
    }
  }

  void _showAddPreferenceDialog(String title, String key) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF7FBF9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: const Color(0xFF1E3C44),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Add new item...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    borderSide: const BorderSide(color: Color(0xFF6EC6B3), width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _addPreference(key, controller.text);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4D9489), Color(0xFF3B7F75)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x243B7F75),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'ADD ITEM',
                        style: TextStyle(
                          fontFamily: 'Doto',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: const Color(0xFFE8F4F1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPreferenceOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FBF9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPDATE PREFERENCES',
              style: TextStyle(
                fontFamily: 'Doto',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
                color: const Color(0xFF1E3C44),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.headphones_rounded, color: Color(0xFF38887A)),
              title: Text('Add Music', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddPreferenceDialog('ADD MUSIC', 'music');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded, color: Color(0xFF38887A)),
              title: Text('Add Movie', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddPreferenceDialog('ADD MOVIE', 'movies');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_run_rounded, color: Color(0xFF38887A)),
              title: Text('Add Activity', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddPreferenceDialog('ADD ACTIVITY', 'activities');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFDDE7E1),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFDDE7E1),
                      const Color(0xFFC5D7D1).withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3C44).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: SnakeLoadingIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFDDE7E1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.24),
                    const Color(0xFFDDE7E1),
                  ],
                  stops: const [0.0, 0.24],
                ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildHeroGlassCard(),
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
                                  _showEditPreferenceOptionsDialog();
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
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF244A44), size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'PROFILE',
            style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 22,
            fontWeight: FontWeight.w800,
          color: const Color(0xFF244A44),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGlassSection({required String title, required Widget child, VoidCallback? onEdit, bool isHero = false}) {
    Widget innerContainer = Container(
      width: double.infinity,
      padding: isHero ? const EdgeInsets.fromLTRB(16, 10, 16, 10) : const EdgeInsets.all(24),
      decoration: isHero
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3C44).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
    );

    if (isHero) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: innerContainer,
        ),
      );
    }

    return innerContainer;
  }

  Widget _buildHeroGlassCard() {
    final user = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.isNotEmpty ? _nameController.text : (user?.displayName ?? "Explorer");
    final fallbackUsername = (user?.email ?? 'user').split('@').first.toLowerCase();
    final rawUsername = _usernameController.text.trim();
    final cleanUsername = rawUsername.startsWith('@') ? rawUsername.substring(1) : rawUsername;
    final displayUsername = cleanUsername.isNotEmpty ? cleanUsername : fallbackUsername;
    
    final savedSeed = _profileData?['avatar_seed'] ?? displayUsername;
    final seed = Uri.encodeComponent(savedSeed);
    final gender = _profileData?['gender'];
    
    String genderParams = "";
    if (gender == 'Male') {
      genderParams = "&hair=variant02,variant03,variant05,variant07,variant08,variant23,variant24,variant26";
    } else if (gender == 'Female') {
      genderParams = "&hair=variant01,variant04,variant09,variant10,variant11,variant12,variant13,variant14,variant15,variant16";
    }

    final avatarUrl = "https://api.dicebear.com/7.x/lorelei/svg?seed=$seed&backgroundColor=eaf7f2&baseColor=f3fbf8&hairColor=3b7f75&eyesColor=3b7f75&eyebrowsColor=3b7f75&mouthColor=3b7f75&accessoriesColor=3b7f75&skinColor=faf4ee&clothingColor=3b7f75&eyes=variant01,variant02&mouth=happy01,happy02$genderParams";

    return _buildGlassSection(
      title: "", // Hides the main title since we use a custom top
      isHero: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: _buildHeroAuraBackground(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF7F2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: GestureDetector(
                            onTap: () => _isEditingBio ? _showAvatarGenderSelector() : null,
                            child: SvgPicture.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF6EC6B3), Color(0xFF2D726B)],
                                  ),
                                ),
                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isEditingBio = !_isEditingBio);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D726B),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isEditingBio
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                    fontFamily: 'Doto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF244A44),
                                    letterSpacing: -0.3,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Your name",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 24,
                                child: TextField(
                                  controller: _usernameController,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF38887A),
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: "@",
                                    prefixStyle: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF38887A),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    hintText: "username",
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildSocialStatCol("${_profileData?['followers'] ?? 0}", "Followers"),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      color: const Color(0xFFB8D3CC).withValues(alpha: 0.5),
                                    ),
                                    _buildSocialStatCol("${_profileData?['following'] ?? 0}", "Following"),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      color: const Color(0xFFB8D3CC).withValues(alpha: 0.5),
                                    ),
                                    _buildSocialStatCol("${_profileData?['hearts'] ?? 0}", "Hearts"),
                                  ],
                                ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _isEditingBio = true),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Doto',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF244A44),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "@$displayUsername",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF38887A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildSocialStatCol("${_profileData?['followers'] ?? 0}", "Followers"),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      color: const Color(0xFFB8D3CC).withValues(alpha: 0.5),
                                    ),
                                    _buildSocialStatCol("${_profileData?['following'] ?? 0}", "Following"),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      color: const Color(0xFFB8D3CC).withValues(alpha: 0.5),
                                    ),
                                    _buildSocialStatCol("${_profileData?['hearts'] ?? 0}", "Hearts"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildBioBox(
                isEditing: _isEditingBio,
                onTap: () => setState(() => _isEditingBio = true),
              ),
              if (_isEditingBio) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _saveBio,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color.fromRGBO(45, 114, 107, 1).withValues(alpha: 0.85),
                              const Color.fromRGBO(24, 79, 75, 1).withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFFB4FFF1).withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Save Profile",
                          style: TextStyle(
                            fontFamily: 'Doto',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAuraBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        final t = _gradientController.value;
        final leftShift = -30 + (t * 50);
        final topShift = -20 + ((1 - t) * 35);
        final rightShift = -20 + ((1 - t) * 40);
        final bottomShift = -30 + (t * 45);

        return Stack(
          children: [
            Positioned(
              left: leftShift,
              top: topShift,
              child: _buildAuraBlob(size: 190, color: const Color(0xFF6EC6B3)),
            ),
            Positioned(
              right: rightShift,
              bottom: bottomShift,
              child: _buildAuraBlob(size: 230, color: const Color(0xFFB9E7DA)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuraBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBioBox({required bool isEditing, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isEditing ? Colors.transparent : Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: isEditing ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isEditing ? Colors.transparent : const Color(0xFF8BBDA8).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.format_quote_rounded,
                color: Color(0xFF8BBDA8),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: _bioController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A6862),
                      ),
                      decoration: InputDecoration(
                        hintText: "Add a short bio...",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: const Color(0xFF6F8A83),
                        ),
                      ),
                    )
                  : Text(
                      _bioController.text.isEmpty ? "Add a short bio..." : _bioController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A6862),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSocialStatCol(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E3C44),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF5F7380),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  // ignore: unused_element
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Doto',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF244A44),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF38887A),
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
    final activities = List<String>.from(preferences?['activities'] ?? []).map((e) => _sanitize(e)).toList();
    
    if (music.isEmpty && movies.isEmpty && activities.isEmpty) {
      return Text(
        "No preferences added yet. Tap the edit icon to add some!",
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF5F7380)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (music.isNotEmpty) ...[
          _PreferenceSection(icon: Icons.headphones_rounded, title: "Sonic Selection", items: music, filled: true),
          const SizedBox(height: 16),
        ],
        if (movies.isNotEmpty) ...[
          _PreferenceSection(icon: Icons.videocam_rounded, title: "Visual Preference", items: movies, filled: false),
          const SizedBox(height: 16),
        ],
        if (activities.isNotEmpty) ...[
          _PreferenceSection(icon: Icons.directions_run_rounded, title: "Activities", items: activities, filled: true),
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
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSignOut,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4D9489), Color(0xFF3B7F75)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x243B7F75),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: Color(0xFFE8F4F1),
                    ),
                  ),
                ),
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
        color: const Color(0xFF244A44).withValues(alpha: 0.6),
      ),
    );
  }
}

class _InterestPill extends StatelessWidget {
  final String label;
  const _InterestPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF38887A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF244A44),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
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
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D726B).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFF38887A), size: 24),
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
            color: filled ? const Color(0xFF2D726B).withValues(alpha: 0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6EC6B3).withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2D726B)),
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
                  color: const Color(0xFF244A44).withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((i) => ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                        child: Text(
                          i,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF244A44),
                          ),
                        ),
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
