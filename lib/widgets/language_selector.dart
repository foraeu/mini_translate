import 'package:flutter/material.dart';

/// 语言选择器组件
/// 用于选择源语言和目标语言
class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<String> languages;
  final Function(String) onLanguageChanged;
  final String label;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedLanguage,
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.primary,
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(12),
        isDense: true,
        underline: const SizedBox(),
        items: languages.map((String language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onLanguageChanged(newValue);
          }
        },
      ),
    );
  }
}

/// 语言交换按钮组件
/// 用于快速交换源语言和目标语言
class LanguageSwapButton extends StatelessWidget {
  final VoidCallback onSwap;

  const LanguageSwapButton({
    super.key,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.swap_horiz,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
      onPressed: onSwap,
      tooltip: '交换语言',
      splashRadius: 24,
    );
  }
}
