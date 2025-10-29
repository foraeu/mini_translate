import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/config_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_input.dart';
import '../widgets/translation_output.dart';

/// 主翻译页面
/// 提供文本输入、语言选择和翻译功能
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 支持的语言列表
  static const List<String> sourceLanguages = [
    '自动',
    '中文',
    '英文',
    '日文',
    '韩文',
    '法文',
    '德文',
    '西班牙文',
    '俄文',
    '阿拉伯文',
    '葡萄牙文',
  ];

  static const List<String> targetLanguages = [
    '中文',
    '英文',
    '日文',
    '韩文',
    '法文',
    '德文',
    '西班牙文',
    '俄文',
    '阿拉伯文',
    '葡萄牙文',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除 AppBar，节省空间
      body: Consumer2<TranslationProvider, ConfigProvider>(
        builder: (context, translationProvider, configProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 配置状态提示
                if (!configProvider.hasConfig)
                  _buildConfigWarning(context),
                
                if (!configProvider.hasConfig)
                  const SizedBox(height: 12),
                
                // 语言选择区域
                _buildLanguageSelector(context, translationProvider),
                
                const SizedBox(height: 16),
                
                // 输入区域
                TranslationInput(
                  text: translationProvider.sourceText,
                  onTextChanged: translationProvider.setSourceText,
                  onClear: translationProvider.clearInput,
                  wordCount: translationProvider.wordCount,
                ),
                
                const SizedBox(height: 12),
                
                // 翻译按钮
                _buildTranslateButton(
                  context,
                  translationProvider,
                  configProvider,
                ),
                
                const SizedBox(height: 16),
                
                // 输出区域
                TranslationOutput(
                  text: translationProvider.translatedText,
                  isLoading: translationProvider.isTranslating,
                ),
                
                // 错误提示
                if (translationProvider.errorMessage != null)
                  _buildErrorMessage(context, translationProvider),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  /// 构建配置警告
  Widget _buildConfigWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '请先在设置中配置API',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建语言选择器
  Widget _buildLanguageSelector(
    BuildContext context,
    TranslationProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LanguageSelector(
          selectedLanguage: provider.sourceLang,
          languages: sourceLanguages,
          onLanguageChanged: provider.setSourceLang,
          label: '源语言',
        ),
        LanguageSwapButton(
          onSwap: provider.swapLanguages,
        ),
        LanguageSelector(
          selectedLanguage: provider.targetLang,
          languages: targetLanguages,
          onLanguageChanged: provider.setTargetLang,
          label: '目标语言',
        ),
      ],
    );
  }

  /// 构建翻译按钮
  Widget _buildTranslateButton(
    BuildContext context,
    TranslationProvider translationProvider,
    ConfigProvider configProvider,
  ) {
    final isEnabled = configProvider.hasConfig &&
        translationProvider.sourceText.isNotEmpty &&
        !translationProvider.isTranslating;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                final config = configProvider.currentConfig;
                if (config != null) {
                  translationProvider.translate(config);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF3B82F6), // Tailwind Blue
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E7EB), // Gray-200
          disabledForegroundColor: const Color(0xFF9CA3AF), // Gray-400
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: translationProvider.isTranslating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '翻译',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 构建错误消息
  Widget _buildErrorMessage(
    BuildContext context,
    TranslationProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: provider.clearError,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }
}
