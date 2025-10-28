import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/translation_provider.dart';
import '../providers/config_provider.dart';
import '../models/translation_history.dart';

/// 历史记录页面
/// 显示翻译历史和收藏列表
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedCards = {}; // 跟踪展开的卡片

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部标签栏和操作按钮
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      tabs: const [
                        Tab(text: '全部', icon: Icon(Icons.history)),
                        Tab(text: '收藏', icon: Icon(Icons.star)),
                        Tab(text: '生词本', icon: Icon(Icons.book)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () => _showClearHistoryDialog(context),
                    tooltip: '清空历史',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<TranslationProvider>(
                builder: (context, provider, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // 全部历史
                      _buildHistoryList(context, provider.histories, provider),
                      // 收藏列表
                      _buildHistoryList(context, provider.favorites, provider),
                      // 生词本（按掌握程度分组）
                      _buildVocabularyGroupedList(context, provider.vocabularies, provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建历史记录列表
  Widget _buildHistoryList(
    BuildContext context,
    List<TranslationHistory> histories,
    TranslationProvider provider,
  ) {
    if (histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无记录',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshHistories();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final history = histories[index];
          return _buildHistoryCard(context, history, provider, showMasteryIndicator: false);
        },
      ),
    );
  }

  /// 构建按掌握程度分组的生词本列表
  Widget _buildVocabularyGroupedList(
    BuildContext context,
    List<TranslationHistory> vocabularies,
    TranslationProvider provider,
  ) {
    if (vocabularies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '生词本为空',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '翻译单词后点击书本图标加入生词本',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    // 按掌握程度分组
    final grouped = <int, List<TranslationHistory>>{};
    for (var vocab in vocabularies) {
      grouped.putIfAbsent(vocab.masteryLevel, () => []).add(vocab);
    }

    // 排序：未掌握的在前
    final sortedLevels = grouped.keys.toList()..sort();

    // 计算统计数据
    final total = vocabularies.length;
    final mastered = vocabularies.where((v) => v.masteryLevel == 2).length;
    final learning = vocabularies.where((v) => v.masteryLevel == 1).length;
    final notStarted = vocabularies.where((v) => v.masteryLevel == 0).length;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshHistories();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 统计卡片
          _buildStatisticsCard(context, total, mastered, learning, notStarted),
          const SizedBox(height: 16),
          // 分组列表
          ...sortedLevels.map((level) {
            final words = grouped[level]!;
            return _buildMasteryGroup(context, level, words, provider);
          }),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCard(
    BuildContext context,
    int total,
    int mastered,
    int learning,
    int notStarted,
  ) {
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
                  child: _buildStatItem(
                    context,
                    '总词数',
                    total.toString(),
                    Colors.blue[400]!,
                    Icons.book,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '已掌握',
                    mastered.toString(),
                    Colors.green[500]!,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '学习中',
                    learning.toString(),
                    Colors.orange[400]!,
                    Icons.pending,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '待学习',
                    notStarted.toString(),
                    Colors.grey[400]!,
                    Icons.circle_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
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

  /// 构建掌握程度分组
  Widget _buildMasteryGroup(
    BuildContext context,
    int level,
    List<TranslationHistory> words,
    TranslationProvider provider,
  ) {
    final masteryTexts = ['未学习', '学习中', '已掌握'];
    final masteryColors = [
      Colors.grey[400]!,
      Colors.orange[400]!,
      Colors.green[500]!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: masteryColors[level],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                masteryTexts[level],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: masteryColors[level],
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(3, (index) {
                return Icon(
                  index < level ? Icons.star : Icons.star_border,
                  size: 16,
                  color: index < level ? masteryColors[level] : Colors.grey[300],
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: masteryColors[level].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${words.length} 个',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: masteryColors[level],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 单词网格
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((word) => _buildWordChip(context, word, provider, masteryColors[level])).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 构建单词标签
  Widget _buildWordChip(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
    Color color,
  ) {
    return InkWell(
      onTap: () => _showWordDetailDialog(context, history, provider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          history.sourceText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  /// 显示单词详细信息对话框
  void _showWordDetailDialog(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        history.sourceText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 语言方向和时间
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${history.sourceLang} → ${history.targetLang}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(history.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 翻译内容
                Text(
                  '翻译',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  history.translatedText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                // 掌握程度
                _buildMasteryIndicator(context, history, provider),
                const SizedBox(height: 20),
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          provider.toggleFavorite(history);
                        },
                        icon: Icon(
                          history.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                        ),
                        label: Text(history.isFavorite ? '已收藏' : '收藏'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: history.isFavorite ? Colors.red : Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final error = await provider.toggleVocabulary(history);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('移出生词本'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[400],
                        ),
                      ),
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

  /// 构建历史记录卡片
  Widget _buildHistoryCard(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider, {
    bool showMasteryIndicator = true,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isExpanded = _expandedCards.contains(history.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: Colors.white, // 使用纯白色背景
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedCards.remove(history.id);
            } else {
              _expandedCards.add(history.id);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 如果是生词本且需要显示熟练度指示器
              if (history.isVocabulary && showMasteryIndicator) ...[
                _buildMasteryIndicator(context, history, provider),
                const SizedBox(height: 8),
              ],
              // 源文本 - 生词本中的单词用更大更醒目的样式
              Text(
                history.sourceText,
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: history.isVocabulary ? 18 : 15,
                  fontWeight: history.isVocabulary ? FontWeight.w600 : FontWeight.w500,
                  height: 1.4,
                  color: history.isVocabulary 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // 翻译结果
              Text(
                history.translatedText,
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
                        '${history.sourceLang} → ${history.targetLang}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(history.timestamp),
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
                      history.isVocabulary ? Icons.book : Icons.book_outlined,
                      size: 20,
                      color: history.isVocabulary
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () async {
                      final error = await provider.toggleVocabulary(history);
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    tooltip: history.isVocabulary ? '移出生词本' : '加入生词本',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  // 收藏按钮
                  IconButton(
                    icon: Icon(
                      history.isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: history.isFavorite
                          ? Colors.amber
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () => provider.toggleFavorite(history),
                    tooltip: history.isFavorite ? '取消收藏' : '收藏',
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
                    onPressed: () => _retranslate(context, history, provider),
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
                    onPressed: () => _deleteHistory(context, history, provider),
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
  void _retranslate(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final config = configProvider.currentConfig;
    
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置API')),
      );
      return;
    }
    
    provider.retranslateFromHistory(history, config);
    
    // 切换到翻译页面
    DefaultTabController.of(context).animateTo(0);
  }

  /// 删除历史记录
  void _deleteHistory(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
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
              provider.deleteHistory(history.id);
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

  /// 构建掌握程度指示器
  Widget _buildMasteryIndicator(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
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

  /// 显示清空历史对话框
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史记录'),
        content: const Text('确定要清空"全部"栏目下的普通记录吗？\n\n收藏和生词本不会被清空。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TranslationProvider>(context, listen: false)
                  .clearAllHistory();
              Navigator.pop(context);
            },
            child: Text(
              '清空',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
