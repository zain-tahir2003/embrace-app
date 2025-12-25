import 'package:flutter/material.dart';
import '../controllers/journal_controller.dart';
import '../../../core/utils/mood_analyzer.dart';
import 'widgets/mood_pie_chart.dart';

class WeeklyAnalysisScreen extends StatelessWidget {
  final JournalController controller;

  const WeeklyAnalysisScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final journals = controller.journals;

    // 1. AGGREGATE DATA FOR CHART
    Map<String, int> moodCounts = {};
    // 2. AGGREGATE TEXT FOR TRIGGERS
    List<String> allNegativeText = [];

    for (var entry in journals) {
      final moodEmoji = entry.mood ?? '📝';
      final label = MoodAnalyzer.getLabel(moodEmoji);

      moodCounts[label] = (moodCounts[label] ?? 0) + 1;

      // Collect text if mood is "Bad"
      if (['Sad', 'Angry', 'Anxious', 'Tired'].contains(label)) {
        allNegativeText.add("${entry.title} ${entry.content}");
      }
    }

    // Determine Dominant Mood
    String dominantMood = "Neutral";
    int maxCount = 0;
    moodCounts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        dominantMood = key;
      }
    });

    // Determine Triggers
    Map<String, int> triggerCounts = {};
    for (var text in allNegativeText) {
      final triggers = MoodAnalyzer.getPotentialTriggers(text);
      for (var t in triggers) {
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
    }
    // Sort Triggers by frequency
    final sortedTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTriggers = sortedTriggers.take(3).map((e) => e.key).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Analysis"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Using onSurface ensures the text is visible in both Light and Dark modes
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: journals.isEmpty
          ? const Center(child: Text("No journals to analyze yet."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. THE PIE CHART ---
                  const Text("Mood Breakdown",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // Using modern withValues instead of deprecated withOpacity
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10)
                      ],
                    ),
                    child: MoodPieChart(
                      data: moodCounts,
                      getColor: (cat) => MoodAnalyzer.getColor(cat),
                      // FIX: Pass the card color here so the chart's center matches the background
                      holeColor: Theme.of(context).cardColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 2. SUMMARY & ADVICE ---
                  const Text("Insights & Advice",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // DOMINANT MOOD CARD
                  _buildInsightCard(
                    context,
                    title: "Your Dominant Mood: $dominantMood",
                    content: MoodAnalyzer.getAdvice(dominantMood),
                    icon: Icons.psychology,
                    color: Color(MoodAnalyzer.getColor(dominantMood)),
                  ),

                  const SizedBox(height: 16),

                  // TRIGGERS CARD (Only show if we have negative data)
                  if (topTriggers.isNotEmpty && dominantMood != "Happy")
                    _buildInsightCard(
                      context,
                      title: "Potential Triggers",
                      content:
                          "Based on your bad days, these seem to be affecting you:\n\n• ${topTriggers.join('\n• ')}",
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orangeAccent,
                    ),

                  // POSITIVE REINFORCEMENT (If Happy)
                  if (dominantMood == "Happy")
                    _buildInsightCard(
                      context,
                      title: "Keep it up!",
                      content:
                          "You are having a great run! Look back at your journals to remember what made these days special.",
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInsightCard(BuildContext context,
      {required String title,
      required String content,
      required IconData icon,
      required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }
}
