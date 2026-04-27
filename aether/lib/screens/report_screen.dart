import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/report_service.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.report});

  final MentalHealthReport report;

  @override
  Widget build(BuildContext context) {
    final trendStyle = _trendStyle(report.trend);
    final stressStyle = _stressStyle(report.stressLevel);
    final riskStyle = _riskStyle(
      riskFlags: report.riskFlags,
      stressLevel: report.stressLevel,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mental Health Report',
          style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRiskBanner(context, riskStyle),
            const SizedBox(height: AppSpacing.md),
            _buildOverviewCard(context),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildTrendCard(context, trendStyle)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildDominantEmotionCard(context)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStressLevelCard(context, stressStyle),
            const SizedBox(height: AppSpacing.md),
            _buildEmotionalVariabilityCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildEmotionDistributionCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildTriggersCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildBehavioralInsightsCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildStressCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildSummaryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final isSingleEntry = report.totalEntries == 1;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildMetricRow('Total Entries', report.totalEntries.toString()),
          _buildMetricRow(
            'Average Sentiment',
            report.averageSentiment.toStringAsFixed(2),
          ),
          _buildMetricRow('Dominant Emotion', report.dominantEmotion),
          if (isSingleEntry) ...[
            _buildMetricRow('Keystroke Emotion', report.keystrokeEmotion),
            _buildMetricRow(
              'Keystroke Confidence',
              '${(report.keystrokeConfidence * 100).toStringAsFixed(1)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStressCard(BuildContext context) {
    final color = report.highStressDetected ? Colors.red : Colors.green;
    final message = report.highStressDetected
        ? 'High stress detected'
        : 'No significant stress detected';

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return AppCard(
      color: const Color(0xFFF1F7FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.summary.isEmpty
                ? 'No data available for this period.'
                : report.summary,
            style: const TextStyle(height: 1.45, color: Color(0xFF2A3C54)),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBanner(BuildContext context, _RiskStyle riskStyle) {
    return AppCard(
      color: riskStyle.background,
      child: Row(
        children: [
          Icon(riskStyle.icon, color: riskStyle.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskStyle.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: riskStyle.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stress level: ${_titleCase(report.stressLevel)}',
                  style: TextStyle(color: riskStyle.foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context, _TrendStyle trendStyle) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A45),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: trendStyle.color.withValues(alpha: 0.14),
                child: Icon(trendStyle.icon, color: trendStyle.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _titleCase(report.trend),
                  style: TextStyle(
                    color: trendStyle.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDominantEmotionCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dominant Emotion',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A45),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.mood_outlined, color: Color(0xFF415A77)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _titleCase(report.dominantEmotion),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A3C54),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStressLevelCard(BuildContext context, _StressStyle stressStyle) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.monitor_heart_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Stress Level',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A45),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: stressStyle.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _titleCase(report.stressLevel),
              style: TextStyle(
                color: stressStyle.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalVariabilityCard(BuildContext context) {
    final normalized = report.emotionalVariability.toLowerCase();
    final isUnstable = normalized == 'high';
    final statusText = isUnstable ? 'Unstable' : 'Stable';
    final statusColor = isUnstable ? Colors.red : Colors.green;

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.insights_outlined, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emotional Stability',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Variability: ${_titleCase(report.emotionalVariability)}',
            style: const TextStyle(color: Color(0xFF546E7A), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDistributionCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotion Distribution',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (report.emotionDistribution.isEmpty)
            const Text('No emotion data available.')
          else
            ...report.emotionDistribution.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _buildEmotionBar(
                  label: _titleCase(entry.key),
                  value: entry.value,
                  max: _maxMapValue(report.emotionDistribution),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTriggersCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Triggers',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (report.triggerFrequency.isEmpty)
            const Text('No trigger data available.')
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: report.triggerFrequency.entries
                  .map(
                    (entry) => AppChip(
                      label: '${_titleCase(entry.key)} (${entry.value})',
                      isSelected: false,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBehavioralInsightsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Behavioral Insights',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (report.behavioralInsights.isEmpty)
            const Text('No behavioral insights available yet.')
          else
            ...report.behavioralInsights.map(
              (insight) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: const Color(0xFFDCE7F3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.brightness_1,
                        size: 8,
                        color: Color(0xFF456C93),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(insight)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  _TrendStyle _trendStyle(String trend) {
    final normalized = trend.toLowerCase();
    if (normalized == 'improving') {
      return const _TrendStyle(icon: Icons.trending_up, color: Colors.green);
    }
    if (normalized == 'declining') {
      return const _TrendStyle(icon: Icons.trending_down, color: Colors.red);
    }
    return const _TrendStyle(icon: Icons.trending_flat, color: Colors.grey);
  }

  _StressStyle _stressStyle(String stressLevel) {
    final normalized = stressLevel.toLowerCase();
    if (normalized == 'high') {
      return const _StressStyle(
        background: Color(0xFFFFEBEE),
        text: Color(0xFFC62828),
      );
    }
    if (normalized == 'moderate') {
      return const _StressStyle(
        background: Color(0xFFFFF3E0),
        text: Color(0xFFEF6C00),
      );
    }
    return const _StressStyle(
      background: Color(0xFFE8F5E9),
      text: Color(0xFF2E7D32),
    );
  }
}

Widget _buildEmotionBar({
  required String label,
  required int value,
  required int max,
}) {
  final safeMax = max <= 0 ? 1 : max;
  final ratio = value / safeMax;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 6),
      LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                height: 10,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                height: 10,
                width: constraints.maxWidth * ratio,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D9DC5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

int _maxMapValue(Map<String, int> data) {
  if (data.isEmpty) return 0;
  return data.values.reduce((a, b) => a > b ? a : b);
}

_RiskStyle _riskStyle({
  required List<String> riskFlags,
  required String stressLevel,
}) {
  if (riskFlags.isNotEmpty || stressLevel.toLowerCase() == 'high') {
    return const _RiskStyle(
      label: 'High Risk',
      background: Color(0xFFFFEBEE),
      foreground: Color(0xFFB71C1C),
      icon: Icons.warning_amber_rounded,
    );
  }

  if (stressLevel.toLowerCase() == 'moderate') {
    return const _RiskStyle(
      label: 'Moderate Stress',
      background: Color(0xFFFFF3E0),
      foreground: Color(0xFFE65100),
      icon: Icons.error_outline,
    );
  }

  return const _RiskStyle(
    label: 'Stable',
    background: Color(0xFFE8F5E9),
    foreground: Color(0xFF1B5E20),
    icon: Icons.verified_outlined,
  );
}

class _RiskStyle {
  const _RiskStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

class _TrendStyle {
  const _TrendStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class _StressStyle {
  const _StressStyle({required this.background, required this.text});

  final Color background;
  final Color text;
}
