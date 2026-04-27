// User profile UI and related small models used for displaying
// account information, badges, streaks and progress. This file
// contains simple demo data and UI components for the profile view.
import 'package:flutter/material.dart';
// Using local font 'Doto' (declared in pubspec.yaml)

// Design system colors
const Color kPrimaryTeal = Color(0xFF6EC6B3);
const Color kPrimaryTealDark = Color(0xFF4DA692);
const Color kBackground = Color(0xFFF5F7F6);
const double kRadius = 20.0;

class UserProfile {
  final String username;
  final String fullName;
  final int followers;
  final int following;
  final List<String> tags;
  final List<BadgeModel> badges;
  final int streak;
  final double goalProgress;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.followers,
    required this.following,
    required this.tags,
    required this.badges,
    required this.streak,
    required this.goalProgress,
  });
}

class BadgeModel {
  final String title;
  final IconData icon;
  final Color color;

  BadgeModel({required this.title, required this.icon, required this.color});
}

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;
  final VoidCallback? onSignOut;

  const ProfileScreen({Key? key, this.user, this.onSignOut}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  late final UserProfile _user;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Fallback demo user when not provided (still dynamic)
    _user = widget.user ?? UserProfile(
      username: '@johndoe',
      fullName: 'John Doe',
      followers: 1240,
      following: 312,
      tags: ['Mindfulness', 'Sleep', 'Anxiety', 'Breathing', 'Daily Journal'],
      badges: List.generate(6, (i) => BadgeModel(title: 'Badge ${i+1}', icon: Icons.self_improvement, color: const Color.fromARGB(255, 27, 233, 188))),
      streak: 12,
      goalProgress: 0.64,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: const TextStyle(fontFamily: 'Doto', color: kPrimaryTealDark, fontWeight: FontWeight.w600, fontSize: 22)),
        leading: BackButton(color: kPrimaryTealDark),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ProfileHeader(user: _user),
                    const SizedBox(height: 14),
                    TagsSection(tags: _user.tags),
                    const SizedBox(height: 14),
                    StreakGoalsSection(streak: _user.streak, goalProgress: _user.goalProgress),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 60,
            child: _buildSignOut(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onSignOut?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryTealDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text('Sign out', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
    );
  }
}

// ------------------- Widgets -------------------

class ProfileHeader extends StatelessWidget {
  final UserProfile user;

  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        gradient: const LinearGradient(colors: [kPrimaryTeal, Color(0xFFDFF7F2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(user.fullName, style: const TextStyle(fontFamily: 'Doto', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  _statItem('${user.followers}', 'Followers'),
                  const SizedBox(width: 12),
                  _statItem('${user.following}', 'Following'),
                ])
              ],
            ),
          ),
          const SizedBox(width: 12),
          Hero(
            tag: 'profile-avatar-${user.username}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 34)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class TagsSection extends StatelessWidget {
  final List<String> tags;

  const TagsSection({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tags.length, (i) {
            final tag = tags[i];
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 4 : 8, right: i == tags.length - 1 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(tag, style: const TextStyle(fontFamily: 'Poppins', color: kPrimaryTealDark, fontSize: 13)),
              ),
            );
          }),
        ),
      ),
    );
  }
}



class StreakGoalsSection extends StatelessWidget {
  final int streak;
  final double goalProgress;

  const StreakGoalsSection({Key? key, required this.streak, required this.goalProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 360;
      return isNarrow ? Column(children: _children(context)) : Row(children: _children(context));
    });
  }

  List<Widget> _children(BuildContext context) {
    return [
      Expanded(
        child: Container(
          height: 110,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [kPrimaryTeal.withOpacity(0.14), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kPrimaryTeal.withOpacity(0.18), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_fire_department, color: kPrimaryTealDark)),
              const SizedBox(width: 10),
              Text('Streak', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: kPrimaryTealDark)),
            ]),
            const SizedBox(height: 12),
            Text('$streak days', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: kPrimaryTealDark)),
          ]),
        ),
      ),
      const SizedBox(width: 12, height: 12),
      Expanded(
        child: Container(
          height: 110,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))]),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Goals', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: kPrimaryTealDark)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: LinearProgressIndicator(value: goalProgress, color: kPrimaryTeal, backgroundColor: Colors.grey.shade200)),
              const SizedBox(width: 10),
              Text('${(goalProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: kPrimaryTealDark)),
            ])
          ]),
        ),
      ),
    ];
  }
}

