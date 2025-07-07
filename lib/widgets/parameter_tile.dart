import 'package:flutter/material.dart';
import '../models/score_parameter.dart';
import '../utils/constants.dart';

class ParameterTile extends StatelessWidget {
  final ScoreParameter parameter;
  final String sectionId;
  final Function(int) onScoreChanged;
  final Function(String) onRemarksChanged;

  const ParameterTile({
    Key? key,
    required this.parameter,
    required this.sectionId,
    required this.onScoreChanged,
    required this.onRemarksChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parameter Name and Required indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    parameter.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (parameter.isRequired)
                  const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Parameter Description
            Text(
              parameter.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Score Selection
            Text(
              'Score (0-${parameter.maxScore}):',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Score Chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(
                parameter.maxScore + 1,
                    (index) => _buildScoreChip(context, index),
              ),
            ),
            const SizedBox(height: 12),

            // Current Score Display
            if (parameter.score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(parameter.score!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Selected: ${parameter.score} - ${_getScoreLabel(parameter.score!)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Remarks Section
            Text(
              'Remarks:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              onChanged: onRemarksChanged,
              controller: TextEditingController(text: parameter.remarks ?? ''),
              decoration: InputDecoration(
                hintText: 'Enter remarks (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(BuildContext context, int score) {
    final isSelected = parameter.score == score;

    return GestureDetector(
      onTap: () => onScoreChanged(score),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _getScoreColor(score) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _getScoreColor(score) : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Text(
          score.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score <= 3) return Colors.red;
    if (score <= 5) return Colors.orange;
    if (score <= 7) return Colors.yellow.shade700;
    if (score <= 9) return Colors.lightGreen;
    return Colors.green;
  }

  String _getScoreLabel(int score) {
    final labels = Constants.getRatingLabels();
    return labels[score] ?? 'Unknown';
  }
}