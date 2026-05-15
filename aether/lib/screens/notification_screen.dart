// Notification center (demo). Replace mock data with backend-driven
// notifications when available. This screen is read-only and small.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


const Color kPrimaryTeal = Color(0xFF6EC6B3);
const Color kPrimaryTealDark = Color(0xFF4DA692);
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Example notifications list. Replace with real data when available.
  List<Map<String, String>> _mockNotifications() {
    return [
      {
        'avatar': '',
        'text': 'Write your daily journal',
        'time': '2h'
      },
      {
        'avatar': '',
        'text': 'Claim your 50XP bonus for maintaining the streak',
        'time': '6h'
      },
      {
        'avatar': '',
        'text': 'You got a friend request from Aether',
        'time': '1d'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _mockNotifications();

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
          'Notifications',
          style: TextStyle(
            fontFamily: 'Doto',
            fontWeight: FontWeight.w800,
            fontSize: 22,
             color: const Color(0xFF244A44),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded, size: 40, color: Color(0xFF217F66)),
                    ),
                    const SizedBox(height: 18),
                    Text('No notifications', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF6E818D))),
                    const SizedBox(height: 8),
                    Text('When we have something to show, it will appear here.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF4D6A72))),
                  ],
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, i) => const Divider(height: 1, thickness: 1, color: Color(0xFFF2F5F4)),
                itemBuilder: (context, i) {
                  final n = notifications[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                        boxShadow: [BoxShadow(color: const Color(0xFF203A42).withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Center(child: Icon(Icons.person_rounded, color: Color(0xFF217F66), size: 26)),
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: const Color(0xFF203D49)),
                        children: [
                          TextSpan(text: n['text'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    subtitle: Text(n['time'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6E818D))),
                    trailing: SizedBox(
                      width: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 36,
                            decoration: BoxDecoration(color: const Color(0xFFF4F9F7), borderRadius: BorderRadius.circular(8)),
                            child: Center(child: Text('Check', style: GoogleFonts.poppins(color: const Color(0xFF244A44), fontWeight: FontWeight.w600))),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  );
                },
              ),
      ),
    );
  }
}
