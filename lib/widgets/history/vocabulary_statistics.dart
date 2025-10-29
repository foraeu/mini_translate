import 'package:flutter/material.dart';

/// 生词本学习统计卡片
/// 显示总词数、已掌握、学习中、待学习的统计信息
class VocabularyStatistics extends StatelessWidget {
  final int total;
  final int mastered;
  final int learning;
  final int notStarted;

  const VocabularyStatistics({
    super.key,
    required this.total,
    required this.mastered,
    required this.learning,
    required this.notStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '学习统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '总词数',
                    value: total.toString(),
                    color: Colors.blue[400]!,
                    icon: Icons.book,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '已掌握',
                    value: mastered.toString(),
                    color: Colors.green[500]!,
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '学习中',
                    value: learning.toString(),
                    color: Colors.orange[400]!,
                    icon: Icons.pending,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '待学习',
                    value: notStarted.toString(),
                    color: Colors.grey[400]!,
                    icon: Icons.circle_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计项组件
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
