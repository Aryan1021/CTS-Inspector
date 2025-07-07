import 'package:flutter/material.dart';
import '../models/score_parameter.dart';
import 'parameter_tile.dart';

class SectionCard extends StatelessWidget {
  final FormSection section;
  final Function(String sectionId, String parameterId, int score) onScoreChanged;
  final Function(String sectionId, String parameterId, String remarks) onRemarksChanged;
  final int currentScore;
  final int maxScore;

  const SectionCard({
    Key? key,
    required this.section,
    required this.onScoreChanged,
    required this.onRemarksChanged,
    required this.currentScore,
    required this.maxScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = maxScore > 0 ? (currentScore / maxScore) * 100.0 : 0.0;
    final progressValue = percentage / 100.0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Score: $currentScore/$maxScore',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(percentage),
                  ),
                ),
              ],
            ),
          ),

          // Parameters List
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: section.parameters.map((parameter) {
                return ParameterTile(
                  parameter: parameter,
                  sectionId: section.id,
                  onScoreChanged: (score) {
                    onScoreChanged(section.id, parameter.id, score);
                  },
                  onRemarksChanged: (remarks) {
                    onRemarksChanged(section.id, parameter.id, remarks);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 60) return Colors.orange;
    if (percentage < 80) return Colors.yellow.shade700;
    return Colors.green;
  }
}
