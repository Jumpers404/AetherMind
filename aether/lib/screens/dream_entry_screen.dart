// Dream entry and lightweight in-memory DreamService used for saving
// and listing user-submitted dream descriptions. This screen is a
// small playground feature separate from the core journaling flow.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

class Dream {
  Dream({required this.text, required this.tags, required this.mood, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  String text;
  List<String> tags;
  String mood;
  DateTime createdAt;
}

class DreamService {
  static final List<Dream> _dreams = [];

  static List<Dream> getDreams() => List.unmodifiable(_dreams.reversed);
  static void saveDream(Dream d) => _dreams.add(d);
}

class DreamEntryScreen extends StatefulWidget {
  const DreamEntryScreen({super.key});

  @override
  State<DreamEntryScreen> createState() => _DreamEntryScreenState();
}

class _DreamEntryScreenState extends State<DreamEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  final List<String> _availableTags = ['flying', 'falling', 'water', 'lucid', 'familiar place'];
  final Set<String> _selectedTags = {};
  String _mood = 'Neutral';
  bool _isSaving = false;

  final List<String> _moods = ['Calm', 'Happy', 'Neutral', 'Confusing', 'Anxious'];

  void _addTag() {
    final t = _newTagController.text.trim().toLowerCase();
    if (t.isEmpty) return;
    setState(() {
      if (!_availableTags.contains(t)) _availableTags.add(t);
      _selectedTags.add(t);
      _newTagController.clear();
    });
  }

  void _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe your dream first.')));
      return;
    }

    setState(() => _isSaving = true);
    
    // Simulate minor processing delay for a premium feel
    await Future.delayed(const Duration(milliseconds: 600));

    final dream = Dream(text: text, tags: _selectedTags.toList(), mood: _mood);
    DreamService.saveDream(dream);

    String insight = 'Dreams are a window to your subconscious.';
    if (dream.tags.contains('falling')) insight = 'Falling dreams often relate to a sense of losing control or feeling overwhelmed.';
    if (dream.tags.contains('flying')) insight = 'Flying dreams frequently reflect feelings of liberation or a desire for freedom.';
    if (dream.tags.contains('water')) insight = 'Water in dreams often symbolizes our emotions and current emotional state.';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(insight),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ));

    setState(() {
      _isSaving = false;
      _controller.clear();
      _selectedTags.clear();
      _mood = 'Neutral';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: Stack(
        children: [
          const Positioned.fill(
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
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroBanner(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildEntryField(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildTagsSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildMoodSection(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _buildBottomActionArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Dream Recorder',
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DreamHistoryScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.18),
          AppColors.primary.withOpacity(0.05),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nights_stay_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture Your Sleep',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4D46), // Deep teal
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Write down what you saw, felt, or heard while it\'s still fresh.',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF26665D).withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happened?',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary, // Fixes blue focus/selection
                  ),
            ),
            child: TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 10,
              cursorColor: AppColors.primary,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 14.5,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Describe the scene, people, feelings...',
                hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.6)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapsule({
    required String label, 
    required bool isSelected, 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.4) : const Color(0xFFEAF3EF),
          ),
          boxShadow: isSelected ? [] : const [AppShadows.soft],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.label_outline_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Themes & Elements',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._availableTags.map((t) {
              final selected = _selectedTags.contains(t);
              return _buildCapsule(
                label: '#$t',
                isSelected: selected,
                onTap: () => setState(() => selected ? _selectedTags.remove(t) : _selectedTags.add(t)),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Add Custom Tag Block (100% width)
        Container(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 18, right: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFFEAF3EF)),
            boxShadow: const [AppShadows.soft],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newTagController,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Add a new theme or tag...',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              GestureDetector(
                onTap: _addTag,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mood_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'How did you feel?',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _moods.map((m) {
            return _buildCapsule(
              label: m,
              isSelected: _mood == m,
              onTap: () => setState(() => _mood = m),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA).withOpacity(0.9),
        border: const Border(top: BorderSide(color: Color(0xFFEAF3EF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Dream',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DreamHistoryScreen extends StatefulWidget {
  const DreamHistoryScreen({super.key});

  @override
  State<DreamHistoryScreen> createState() => _DreamHistoryScreenState();
}

class _DreamHistoryScreenState extends State<DreamHistoryScreen> {
  String _query = '';
  String _filterMood = '';

  @override
  Widget build(BuildContext context) {
    final all = DreamService.getDreams();
    final filtered = all.where((d) {
      final q = _query.toLowerCase();
      final matchText = d.text.toLowerCase().contains(q);
      final matchTag = d.tags.any((t) => t.toLowerCase().contains(q));
      final matchMood = _filterMood.isEmpty || d.mood == _filterMood;
      return (matchText || matchTag) && matchMood;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: Stack(
        children: [
          const Positioned.fill(
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
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      _buildMoodFilters(),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, idx) => _buildDreamCard(filtered[idx]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Dream History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Doto',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFEAF3EF)), // Added subtle border
        boxShadow: const [AppShadows.soft],
      ),
      child: Center(
        child: TextField(
          cursorColor: AppColors.primary,
          style: const TextStyle(fontSize: 14), // Added to increase text size slightly
          decoration: InputDecoration(
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.search_rounded, color: AppColors.textSecondary.withOpacity(0.7), size: 22),
            ),
            hintText: 'Search dreams, tags...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 14),
            border: InputBorder.none,
            isDense: true, // Help center vertically
            contentPadding: EdgeInsets.zero, // Remove flutter internal padding
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
    );
  }

  Widget _buildCapsule({
    required String label, 
    required bool isSelected, 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.4) : const Color(0xFFEAF3EF),
          ),
          boxShadow: isSelected ? [] : const [AppShadows.soft],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ['Calm', 'Scary', 'Confusing', 'Happy', 'Neutral'].map((m) {
          final sel = _filterMood == m;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _buildCapsule(
              label: m,
              isSelected: sel,
              onTap: () => setState(() => _filterMood = sel ? '' : m),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDreamCard(Dream d) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${d.createdAt.toLocal().day}/${d.createdAt.toLocal().month}/${d.createdAt.toLocal().year}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  d.mood,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            d.text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (d.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: d.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3EF),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No dreams found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
