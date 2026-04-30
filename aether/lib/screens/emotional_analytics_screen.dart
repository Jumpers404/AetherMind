// Emotional analytics view.
// Shows calendar, emotion distribution and pattern insights computed
// from stored journal entries. This is a read-only analytics dashboard.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/emotion_entry.dart';
import '../app_theme.dart';

class EmotionalAnalyticsScreen extends StatefulWidget {
  const EmotionalAnalyticsScreen({super.key});

  @override
  State<EmotionalAnalyticsScreen> createState() => _EmotionalAnalyticsScreenState();
}

class _EmotionalAnalyticsScreenState extends State<EmotionalAnalyticsScreen> {
  late List<EmotionEntry> _entries;
  late List<String> _insights;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _entries = EmotionEntry.generateMockData();
    _insights = EmotionAnalyticsLogic.generateInsights(_entries);
  }

  final _softCardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Wash
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEAF4F2),
                    Color(0xFFF8FBFA),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroInsightCard(decoration: _softCardDecoration),
                        const SizedBox(height: 24),
                        _MonthlyCalendarCard(
                          entries: _entries,
                          selectedMonth: _selectedMonth,
                          decoration: _softCardDecoration,
                          onMonthChanged: (newMonth) {
                            setState(() {
                              _selectedMonth = newMonth;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _EmotionDistributionStrip(entries: _entries, decoration: _softCardDecoration),
                        const SizedBox(height: 24),
                        _PatternInsightsSection(insights: _insights),
                        const SizedBox(height: 24),
                        _ReflectionCTA(decoration: _softCardDecoration),
                        const SizedBox(height: 48),
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
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Emotional Analytics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Doto',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                Text(
                  'A reflection of how you’ve been feeling',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF7A7A7A).withOpacity(0.8),
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

class _HeroInsightCard extends StatelessWidget {
  final BoxDecoration decoration;
  const _HeroInsightCard({required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_rounded, color: Color(0xFF4DB6AC), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "You've been feeling balanced this week with slight midweek stress.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
                height: 1.4,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MonthlyCalendarCard extends StatelessWidget {
  final List<EmotionEntry> entries;
  final DateTime selectedMonth;
  final BoxDecoration decoration;
  final Function(DateTime) onMonthChanged;

  const _MonthlyCalendarCard({
    required this.entries,
    required this.selectedMonth,
    required this.decoration,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday % 7; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 20),
          _buildWeekdayLabels(),
          const SizedBox(height: 12),
          _buildCalendarGrid(daysInMonth, weekdayOffset),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthName = _getMonthName(selectedMonth.month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$monthName ${selectedMonth.year}',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E2E2E),
          ),
        ),
        Row(
          children: [
            _MonthNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month - 1)),
            ),
            const SizedBox(width: 8),
            _MonthNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month + 1)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels.map((label) => SizedBox(
        width: 32,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7A7A7A).withOpacity(0.6),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int offset) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemBuilder: (context, index) {
        final day = index - offset + 1;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(selectedMonth.year, selectedMonth.month, day);
        final entry = entries.cast<EmotionEntry?>().firstWhere(
          (e) => e != null && e.date.year == date.year && e.date.month == date.month && e.date.day == date.day,
          orElse: () => null,
        );

        final emotionColor = entry != null ? EmotionEntry.getColor(entry.mood) : Colors.grey.shade300.withOpacity(0.5);

        return _DayTile(
          day: '$day',
          color: emotionColor,
          hasData: entry != null,
          onTap: () => _showDayDetails(context, date, entry),
        );
      },
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, EmotionEntry? entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getWeekdayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (entry != null ? EmotionEntry.getColor(entry.mood) : Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry?.mood.toUpperCase() ?? 'NO DATA',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: entry != null ? EmotionEntry.getColor(entry.mood) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (entry != null) ...[
              Text(
                'Reflection',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"Today felt structured and I managed to stay present despite a few challenges at work. The evening walk really helped clear my mind."',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.5,
                  color: const Color(0xFF424242),
                ),
              ),
            ] else 
              Text(
                'No reflections logged for this day.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month];
  }

  String _getWeekdayName(int weekday) {
    const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday];
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4DB6AC)),
      ),
    );
  }
}

class _DayTile extends StatefulWidget {
  final String day;
  final Color color;
  final bool hasData;
  final VoidCallback onTap;

  const _DayTile({
    required this.day,
    required this.color,
    required this.hasData,
    required this.onTap,
  });

  @override
  State<_DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<_DayTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.hasData ? widget.color.withOpacity(0.85) : Colors.grey.shade200.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.hasData ? [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              widget.day,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: widget.hasData ? Colors.white : const Color(0xFF7A7A7A).withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionDistributionStrip extends StatelessWidget {
  final List<EmotionEntry> entries;
  final BoxDecoration decoration;

  const _EmotionDistributionStrip({required this.entries, required this.decoration});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {'good': 0, 'neutral': 0, 'low': 0, 'stressed': 0};
    for (var entry in entries) {
      if (counts.containsKey(entry.mood)) {
        counts[entry.mood] = counts[entry.mood]! + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _EmotionBubble(color: const Color(0xFF66BB6A), count: counts['good']!, label: "Good"),
          _EmotionBubble(color: const Color(0xFFFFCA28), count: counts['neutral']!, label: "Neutral"),
          _EmotionBubble(color: const Color(0xFF42A5F5), count: counts['low']!, label: "Low"),
          _EmotionBubble(color: const Color(0xFFEF5350), count: counts['stressed']!, label: "Stress"),
        ],
      ),
    );
  }
}

class _EmotionBubble extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _EmotionBubble({required this.color, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E2E2E),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7A7A7A),
          ),
        ),
      ],
    );
  }
}

class _PatternInsightsSection extends StatelessWidget {
  final List<String> insights;
  const _PatternInsightsSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4DB6AC), size: 20),
              const SizedBox(width: 10),
              Text(
                'Pattern Insights',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4DB6AC), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ReflectionCTA extends StatelessWidget {
  final BoxDecoration decoration;
  const _ReflectionCTA({required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reflect on your patterns",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Self-awareness is the first step.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF4DB6AC), size: 20),
          ),
        ],
      ),
    );
  }
}
