import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LumosChatScreen extends StatefulWidget {
  const LumosChatScreen({super.key});

  @override
  State<LumosChatScreen> createState() => _LumosChatScreenState();
}

class _LumosChatScreenState extends State<LumosChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _floatController;
  
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! I'm Lumos, your personal mental health companion. How are you feeling today?",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      mood: "calm",
    ),
    _ChatMessage(
      text: "I'm here to listen and help you navigate your emotions.",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      mood: "empathetic",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: _messageController.text.trim(),
        isMe: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: "I'm processing what you shared. Take a deep breath with me while I think.",
            isMe: false,
            timestamp: DateTime.now(),
            mood: "thoughtful",
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Aurora Background
          const Positioned.fill(child: _AuroraBackground()),
          
          // Floating "Mood Particles"
          ...List.generate(5, (index) => _FloatingParticle(
            controller: _floatController,
            index: index,
          )),

          SafeArea(
            child: Column(
              children: [
                _ChatHeader(),
                const _BreathingGuide(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _LiquidChatBubble(
                        message: _messages[index],
                        showMood: !_messages[index].isMe,
                      );
                    },
                  ),
                ),
                _NeonInput(
                  controller: _messageController,
                  onSend: _handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FBF9),
            Color(0xFFF0F7F4),
            Color(0xFFE6F1EC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: _GlowOrb(
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
              size: 400,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _GlowOrb(
              color: const Color(0xFF2FB07E).withValues(alpha: 0.08),
              size: 500,
            ),
          ),
        ],
      ),
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
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF9).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF4DB6AC).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3C44), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/imgs/AppIcons/lumos_avatar.png'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: const Color(0xFF4DB6AC).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lumos',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3C44),
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF2FB07E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Color(0xFF1E3C44), size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E3C44), size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _LiquidChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool showMood;

  const _LiquidChatBubble({required this.message, this.showMood = false});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showMood && message.mood != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Text(
                  message.mood!.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: const Color(0xFF4DB6AC).withValues(alpha: 0.7),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                color: isMe 
                  ? const Color(0xFF4DB6AC).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E3C44),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _NeonInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48, // Reduced height for less bulk
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF4DB6AC).withValues(alpha: 0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.sentiment_satisfied_alt_outlined, color: Color(0xFF5F7380), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: GoogleFonts.poppins(color: const Color(0xFF1E3C44), fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF5F7380).withValues(alpha: 0.5), 
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const Icon(Icons.attach_file_rounded, color: Color(0xFF5F7380), size: 22),
                  const SizedBox(width: 10),
                  const Icon(Icons.camera_alt_outlined, color: Color(0xFF5F7380), size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48, // Reduced send button size
              height: 48, // Reduced send button size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D726B),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D726B).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingGuide extends StatelessWidget {
  const _BreathingGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4DB6AC).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4DB6AC).withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          const _PulseCircle(),
          const SizedBox(width: 12),
          Text(
            'Deep Breath: Inhale...',
            style: GoogleFonts.poppins(
              color: const Color(0xFF80CBC4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  const _PulseCircle();
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(color: Color(0xFF4DB6AC), shape: BoxShape.circle),
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final Animation<double> controller;
  final int index;
  const _FloatingParticle({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value + (index * 0.2);
        final double x = math.sin(t * 2 * math.pi) * 100 + (index * 50);
        final double y = math.cos(t * 2 * math.pi) * 200 + (index * 100);
        return Positioned(
          left: 150 + x,
          top: 300 + y,
          child: Opacity(
            opacity: 0.15,
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(color: Color(0xFF4DB6AC), shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? mood;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.mood,
  });
}

