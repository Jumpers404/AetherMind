import 'package:flutter/material.dart';
import 'package:aether/widgets/auth_flow_loader.dart';

import '../app_theme.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/report_service.dart';
import '../widgets/app_card.dart';
import 'report_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final JournalService _journalService = JournalService();
  final ReportService _reportService = ReportService();

  late Future<List<JournalEntry>> _journalsFuture;

  @override
  void initState() {
    super.initState();
    _journalsFuture = _journalService.getJournalsForUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.userName,
          style: const TextStyle(
            fontFamily: 'Doto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: _journalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const SnakeLoadingIndicator());
          }

          final journals = snapshot.data ?? <JournalEntry>[];
          final report = _reportService.generateReport(journals);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reports', style: AppTextStyles.bodyPrimary),
                    const SizedBox(height: 8),
                    Text(
                      report.totalEntries == 0
                          ? 'No journal data available yet.'
                          : report.summary,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 12),
                    if (report.totalEntries > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportScreen(report: report),
                              ),
                            );
                          },
                          child: const Text('View full report'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Journals', style: AppTextStyles.bodyPrimary),
              const SizedBox(height: AppSpacing.sm),
              if (journals.isEmpty)
                AppCard(
                  child: Text(
                    'No journals found for this patient yet.',
                    style: AppTextStyles.bodySecondary,
                  ),
                )
              else
                ...journals.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTimestamp(entry.timestamp),
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
