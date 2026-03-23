import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onSignOut;
  const ProfileScreen({Key? key, required this.onSignOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
      ? user.displayName!
      : (user?.email?.split('@').first ?? 'Your Name');
    final email = user?.email ?? 'you@example.com';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF203D49)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.doto(
            color: const Color(0xFF203D49),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.92), const Color(0xFFF4F9F7)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1D3D47).withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEAF3EF),
                        boxShadow: [BoxShadow(color: const Color(0xFF203A42).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 6))],
                      ),
                      child: ClipOval(
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, s, e) => const Icon(Icons.person_rounded, size: 42, color: Color(0xFF217F66)))
                            : const Center(child: Icon(Icons.person_rounded, size: 42, color: Color(0xFF217F66))),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF203D49))),
                          const SizedBox(height: 6),
                          Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w500, color: const Color(0xFF6E818D))),
                          const SizedBox(height: 8),
                          Row(children: [
                            Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), decoration: BoxDecoration(color: const Color(0xFFD9F1E7), borderRadius: BorderRadius.circular(10)), child: Text('Premium', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF2D726B), fontWeight: FontWeight.w600))),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ProfileStatCard(title: 'Streak', value: '12'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStatCard(title: 'Check-ins', value: '42'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStatCard(title: 'Minutes', value: '320'),
                ),
              ],
            ),

            const SizedBox(height: 22),
            Expanded(
              child: Center(
                child: Text(
                  'Manage your account, view activity, and sign out from here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: const Color(0xFF4D6A72)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF244A44),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFEAF3EF)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSignOut();
                  },
                  child: Text('Sign out', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileStatCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFF203A42).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6E818D))),
          ],
        ),
      ),
    );
  }
}
