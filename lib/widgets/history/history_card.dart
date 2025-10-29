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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // 主阴影 - 更柔和的立体感
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          // 边缘高光 - 增加层次感
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onExpandToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 如果是生词本且需要显示熟练度指示器
                if (widget.history.isVocabulary && widget.showMasteryIndicator) ...[
                  MasteryIndicator(
                    history: widget.history,
                    provider: widget.provider,
                  ),
                  const SizedBox(height: 10),
                ],
                // 源文本 - 生词本中的单词用更大更醒目的样式
                Text(
                  widget.history.sourceText,
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.history.isVocabulary ? 18 : 15,
                    fontWeight: widget.history.isVocabulary ? FontWeight.w600 : FontWeight.w500,
                    height: 1.4,
                    color: widget.history.isVocabulary 
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                // 翻译结果
                Text(
                  widget.history.translatedText,
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF6B7280),
                  ),
                ),
                // 展开时显示语言和时间
                if (isExpanded) ...[
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.history.sourceLang} → ${widget.history.targetLang}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat.format(widget.history.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
                // 操作按钮 - 始终显示但更紧凑
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 生词本按钮
                    IconButton(
                      icon: Icon(
                        widget.history.isVocabulary ? Icons.book : Icons.book_outlined,
                        size: 18,
                        color: widget.history.isVocabulary
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF9CA3AF),
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
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    // 收藏按钮
                    IconButton(
                      icon: Icon(
                        widget.history.isFavorite ? Icons.star : Icons.star_border,
                        size: 18,
                        color: widget.history.isFavorite
                            ? Colors.amber
                            : const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => widget.provider.toggleFavorite(widget.history),
                      tooltip: widget.history.isFavorite ? '取消收藏' : '收藏',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    // 重新翻译按钮
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Color(0xFF3B82F6),
                      ),
                      onPressed: () => _retranslate(context),
                      tooltip: '重新翻译',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    // 删除按钮
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: () => _deleteHistory(context),
                      tooltip: '删除',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
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
