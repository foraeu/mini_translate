import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';
import '../../providers/config_provider.dart';
import 'mastery_indicator.dart';

/// 历史记录卡片
/// 用于收藏和生词本标签页的详细卡片显示
class HistoryCard extends StatefulWidget {
  final TranslationHistory history;
  final TranslationProvider provider;
  final bool showMasteryIndicator;
  final Set<String> expandedCards;
  final VoidCallback onExpandToggle;

  const HistoryCard({
    super.key,
    required this.history,
    required this.provider,
    this.showMasteryIndicator = true,
    required this.expandedCards,
    required this.onExpandToggle,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isExpanded = widget.expandedCards.contains(widget.history.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onExpandToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 如果是生词本且需要显示熟练度指示器
              if (widget.history.isVocabulary && widget.showMasteryIndicator) ...[
                MasteryIndicator(
                  history: widget.history,
                  provider: widget.provider,
                ),
                const SizedBox(height: 8),
              ],
              // 源文本 - 生词本中的单词用更大更醒目的样式
              Text(
                widget.history.sourceText,
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.history.isVocabulary ? 18 : 15,
                  fontWeight: widget.history.isVocabulary ? FontWeight.w600 : FontWeight.w500,
                  height: 1.4,
                  color: widget.history.isVocabulary 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // 翻译结果
              Text(
                widget.history.translatedText,
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              // 展开时显示语言和时间
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.history.sourceLang} → ${widget.history.targetLang}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(widget.history.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 生词本按钮
                  IconButton(
                    icon: Icon(
                      widget.history.isVocabulary ? Icons.book : Icons.book_outlined,
                      size: 20,
                      color: widget.history.isVocabulary
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () async {
                      final error = await widget.provider.toggleVocabulary(widget.history);
                      if (error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    tooltip: widget.history.isVocabulary ? '移出生词本' : '加入生词本',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  // 收藏按钮
                  IconButton(
                    icon: Icon(
                      widget.history.isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: widget.history.isFavorite
                          ? Colors.amber
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () => widget.provider.toggleFavorite(widget.history),
                    tooltip: widget.history.isFavorite ? '取消收藏' : '收藏',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  // 重新翻译按钮
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _retranslate(context),
                    tooltip: '重新翻译',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  // 删除按钮
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _deleteHistory(context),
                    tooltip: '删除',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 重新翻译
  void _retranslate(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final config = configProvider.currentConfig;
    
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置API')),
      );
      return;
    }
    
    widget.provider.retranslateFromHistory(widget.history, config);
    
    // 切换到翻译页面
    DefaultTabController.of(context).animateTo(0);
  }

  /// 删除历史记录
  void _deleteHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条翻译记录吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.provider.deleteHistory(widget.history.id);
              Navigator.pop(context);
            },
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
