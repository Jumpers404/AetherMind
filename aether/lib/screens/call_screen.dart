import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String avatarAsset;

  const CallScreen({
    super.key,
    required this.name,
    required this.avatarAsset,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      body: Stack(
        children: [
          // Background soft gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7FBF9),
                    Color(0xFFE0F2F1),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating animated orbs
          Positioned(
            top: 100,
            left: -50,
            child: _GlowOrb(
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
              size: 300,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Encryption notice (WhatsApp style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 12, color: Color(0xFF5F7380)),
                    const SizedBox(width: 4),
                    Text(
                      'End-to-end encrypted',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF5F7380),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Avatar and Name
                Column(
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4DB6AC).withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DB6AC).withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            widget.avatarAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.name,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3C44),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ringing...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF4DB6AC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Call Controls
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CallControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic_none,
                            onTap: () => setState(() => _isMuted = !_isMuted),
                            isActive: _isMuted,
                            label: 'Mute',
                          ),
                          _CallControlButton(
                            icon: Icons.bluetooth_audio_rounded,
                            onTap: () {},
                            isActive: false,
                            label: 'Bluetooth',
                          ),
                          _CallControlButton(
                            icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                            onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                            isActive: _isSpeaker,
                            label: 'Speaker',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // End Call Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE57373),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE57373),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String label;

  const _CallControlButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4DB6AC) : const Color(0xFFF0F7F4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF1E3C44),
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF5F7380),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}
