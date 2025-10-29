import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../models/translation_history.dart';
import '../widgets/history/history_list_item.dart';
import '../widgets/history/history_card.dart';
import '../widgets/history/history_detail_dialog.dart';
import '../widgets/history/vocabulary_statistics.dart';
import '../widgets/history/vocabulary_mastery_group.dart';

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
                      // 全部历史 - 使用简洁列表
                      _buildSimpleHistoryList(context, provider.histories, provider),
                      // 收藏列表 - 使用卡片样式
                      _buildCardHistoryList(context, provider.favorites, provider),
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

  /// 构建简洁列表（用于"全部"标签页）
  Widget _buildSimpleHistoryList(
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
          return HistoryListItem(
            history: history,
            onTap: () => HistoryDetailDialog.show(context, history, provider),
          );
        },
      ),
    );
  }

  /// 构建卡片列表（用于"收藏"标签页）
  Widget _buildCardHistoryList(
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
              Icons.star_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无收藏',
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
          return HistoryCard(
            history: history,
            provider: provider,
            showMasteryIndicator: false,
            expandedCards: _expandedCards,
            onExpandToggle: () {
              setState(() {
                if (_expandedCards.contains(history.id)) {
                  _expandedCards.remove(history.id);
                } else {
                  _expandedCards.add(history.id);
                }
              });
            },
          );
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
          VocabularyStatistics(
            total: total,
            mastered: mastered,
            learning: learning,
            notStarted: notStarted,
          ),
          const SizedBox(height: 16),
          // 分组列表
          ...sortedLevels.map((level) {
            final words = grouped[level]!;
            return VocabularyMasteryGroup(
              level: level,
              words: words,
              provider: provider,
            );
          }),
        ],
      ),
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
