import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/fact_model.dart';
import '../widgets/fact_card.dart';
import '../services/fact_reels_service.dart';
import '../services/journal_service.dart';

class FactReelsScreen extends StatefulWidget {
  const FactReelsScreen({super.key});

  @override
  State<FactReelsScreen> createState() => _FactReelsScreenState();
}

class _FactReelsScreenState extends State<FactReelsScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _reflectionController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FactReelsService _factReelsService = FactReelsService();
  final JournalService _journalService = JournalService();
  List<Fact> _reelFacts = sampleFacts;
  int _currentIndex = 0;
  bool _isMuted = false;

  static const List<String> _audioPool = [
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodAwareFacts();
    _playFactAudio(0);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _playFactAudio(int index) async {
    if (index < 0 || index >= _reelFacts.length) {
      return;
    }
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
      final audioUrl = _audioPool[index % _audioPool.length];
      await _audioPlayer.play(
        UrlSource(audioUrl, mimeType: 'audio/mpeg'),
      );
    } catch (_) {
      // Ignore audio errors to keep scrolling smooth.
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }

  Future<void> _loadMoodAwareFacts() async {
    try {
      final journals = await _journalService.getUserJournals();
      if (journals.isEmpty) {
        return;
      }
      final latest = journals.first;
      final hoursAgo = DateTime.now().difference(latest.timestamp).inHours;
      if (hoursAgo > 5) {
        return;
      }

      final emotion = latest.emotion.toLowerCase();
      final preferred = _preferredCategoriesForEmotion(emotion);
      if (preferred.isEmpty) {
        return;
      }

      final matching = <Fact>[];
      final rest = <Fact>[];
      for (final fact in sampleFacts) {
        final category = fact.category.toLowerCase();
        if (preferred.any((p) => category.contains(p))) {
          matching.add(fact);
        } else {
          rest.add(fact);
        }
      }

      if (matching.isEmpty) {
        return;
      }

      setState(() {
        _reelFacts = [...matching, ...rest];
        _currentIndex = 0;
      });
    } catch (_) {
      // Ignore failures to keep reels responsive.
    }
  }

  List<String> _preferredCategoriesForEmotion(String emotion) {
    if (emotion.contains('anx') || emotion.contains('panic') || emotion.contains('worry')) {
      return ['anxiety', 'habits'];
    }
    if (emotion.contains('sad') || emotion.contains('depress') || emotion.contains('down')) {
      return ['self', 'emotions', 'mind'];
    }
    if (emotion.contains('stress') || emotion.contains('overwhelm')) {
      return ['habits', 'emotions', 'anxiety'];
    }
    if (emotion.contains('anger') || emotion.contains('irrit')) {
      return ['emotions', 'mind'];
    }
    if (emotion.contains('tired') || emotion.contains('burnout')) {
      return ['habits', 'self'];
    }
    return [];
  }

  void _nextFact() {
    if (_currentIndex < _reelFacts.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveFact(Fact fact, bool isSaved) async {
    await _factReelsService.setSavedFact(fact, isSaved);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Fact saved to your collection.' : 'Removed from saved.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openReflectDialog(Fact fact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reflection Journal',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What does this fact make you feel?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFA),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: const Color(0xFFEAF3EF)),
                ),
                child: TextField(
                  controller: _reflectionController,
                  cursorColor: AppColors.primary,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write continuously...',
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () {
                    final text = _reflectionController.text.trim();
                    _reflectionController.clear();
                    Navigator.of(ctx).pop();
                    if (text.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reflection saved to Journal.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save to Journal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTextColor = _reelFacts[_currentIndex].textColor;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentTextColor.withValues(alpha: 0.25),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: currentTextColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentTextColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: currentTextColor,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const PageScrollPhysics(),
            allowImplicitScrolling: true,
            itemCount: _reelFacts.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _playFactAudio(index);
            },
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: FactCard(
                  fact: _reelFacts[index],
                  index: index,
                  onSave: (isSaved) => _saveFact(_reelFacts[index], isSaved),
                  onReflect: () => _openReflectDialog(_reelFacts[index]),
                  onNext: _nextFact,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
