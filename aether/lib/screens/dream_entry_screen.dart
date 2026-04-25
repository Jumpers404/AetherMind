import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final List<String> _availableTags = ['flying', 'falling', 'water', 'unknown place', 'familiar person'];
  final Set<String> _selectedTags = {};
  String _mood = 'Neutral';
  bool _isSaving = false;

  void _addTag() {
    final t = _newTagController.text.trim();
    if (t.isEmpty) return;
    setState(() {
      if (!_availableTags.contains(t)) _availableTags.add(t);
      _selectedTags.add(t);
      _newTagController.clear();
    });
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Write a short dream note')));
      return;
    }

    setState(() => _isSaving = true);

    final dream = Dream(text: text, tags: _selectedTags.toList(), mood: _mood);
    DreamService.saveDream(dream);

    // subtle insight mapping
    String insight = 'Dreams can gently reflect your inner thoughts.';
    if (dream.tags.contains('falling')) insight = 'Dreams about falling often reflect a sense of losing control.';
    if (dream.tags.contains('flying')) insight = 'Flying dreams can feel liberating and reflect a wish for freedom.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(insight)));

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
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dream Recorder', style: TextStyle(fontFamily: 'Doto', color: Color(0xFF21464D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capture the scene and feeling of your dream.', style: GoogleFonts.poppins(color: const Color(0xFF5F7380))),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                      child: TextField(
                        controller: _controller,
                        minLines: 6,
                        maxLines: 12,
                        style: GoogleFonts.poppins(),
                        decoration: const InputDecoration.collapsed(hintText: 'What did you see, feel, or experience?'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: Text('Tags', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((t) {
                        final selected = _selectedTags.contains(t);
                        return GestureDetector(
                          onTap: () => setState(() => selected ? _selectedTags.remove(t) : _selectedTags.add(t)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selected ? const Color(0xFFDDF5EA) : const Color(0xFFF5FAF7),
                              border: Border.all(color: selected ? const Color(0xFF8ED7B7) : const Color(0xFFEAF3EF)),
                            ),
                            child: Text(t, style: GoogleFonts.poppins(fontSize: 13, color: selected ? const Color(0xFF1E5944) : const Color(0xFF335D63))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextField(controller: _newTagController, decoration: const InputDecoration(hintText: 'Add tag')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _addTag, child: const Text('Add'))
                    ]),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: Text('Mood', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Calm', 'Scary', 'Confusing', 'Happy', 'Neutral'].map((m) {
                        final sel = _mood == m;
                        return GestureDetector(
                          onTap: () => setState(() => _mood = m),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: sel ? const Color(0xFFDDF5EA) : const Color(0xFFF5FAF7), border: Border.all(color: sel ? const Color(0xFF8ED7B7) : const Color(0xFFEAF3EF))),
                            child: Text(m, style: GoogleFonts.poppins(color: sel ? const Color(0xFF1E5944) : const Color(0xFF335D63))),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF36B37E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Save Dream', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DreamHistoryScreen())), child: const Text('View dream history'))
          ],
        ),
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Dream History', style: TextStyle(color: Color(0xFF21464D), fontFamily: 'Doto'))),
      backgroundColor: const Color(0xFFF5FAF7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(hintText: 'Search dreams, tags, mood'), onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Calm', 'Scary', 'Confusing', 'Happy', 'Neutral']
                  .map(
                    (m) {
                      final sel = _filterMood == m;
                      return GestureDetector(
                        onTap: () => setState(() => _filterMood = sel ? '' : m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: sel ? const Color(0xFFDDF5EA) : const Color(0xFFF5FAF7),
                            border: Border.all(
                              color: sel ? const Color(0xFF8ED7B7) : const Color(0xFFEAF3EF),
                            ),
                          ),
                          child: Text(
                            m,
                            style: GoogleFonts.poppins(
                              color: sel ? const Color(0xFF1E5944) : const Color(0xFF335D63),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final d = filtered[idx];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF203A43).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF21464D))),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF5FAF7), borderRadius: BorderRadius.circular(8)), child: Text(d.mood, style: GoogleFonts.poppins(fontSize: 11))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(d.tags.join(', '), style: GoogleFonts.poppins(color: const Color(0xFF6E818D), fontSize: 12), overflow: TextOverflow.ellipsis)),
                        Text(d.createdAt.toLocal().toString().split(' ').first, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF9AA9AE)))
                      ])
                    ]),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
