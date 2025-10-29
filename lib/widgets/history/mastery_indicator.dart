import 'package:flutter/material.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';

/// 掌握程度指示器
/// 显示当前掌握等级和进度条，支持调整掌握程度
class MasteryIndicator extends StatelessWidget {
  final TranslationHistory history;
  final TranslationProvider provider;

  const MasteryIndicator({
    super.key,
    required this.history,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final level = history.masteryLevel;
    final masteryTexts = ['未学习', '学习中', '已掌握'];
    final masteryColors = [
      Colors.grey[400]!,
      Colors.orange[400]!,
      Colors.green[500]!,
    ];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    masteryTexts[level],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: masteryColors[level],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 星级显示
                  ...List.generate(3, (index) {
                    return Icon(
                      index < level ? Icons.star : Icons.star_border,
                      size: 14,
                      color: index < level ? masteryColors[level] : Colors.grey[300],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),
              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: level / 2,
                  minHeight: 4,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(masteryColors[level]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 调整按钮
        PopupMenuButton<int>(
          icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
          tooltip: '调整掌握程度',
          onSelected: (newLevel) {
            provider.updateMasteryLevel(history, newLevel);
          },
          itemBuilder: (context) => [
            for (int i = 0; i <= 2; i++)
              PopupMenuItem(
                value: i,
                child: Row(
                  children: [
                    ...List.generate(3, (index) {
                      return Icon(
                        index < i ? Icons.star : Icons.star_border,
                        size: 16,
                        color: index < i ? masteryColors[i] : Colors.grey[300],
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(masteryTexts[i]),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
