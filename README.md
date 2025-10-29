# Mini Translate

一个功能丰富、界面简洁的 AI 翻译应用，基于 Flutter 开发，支持 Android 平台。采用模块化架构，代码结构清晰，易于维护和扩展。

## 核心功能

### 智能翻译
- **AI 驱动**: 接入 OpenAI 兼容 API，提供准确的翻译结果
- **自动检测语言**: 智能识别源语言，无需手动选择
- **词典模式**: 翻译英语单词时自动显示音标、词性、释义和双语例句
- **流畅动画**: 翻译结果淡入效果，提升用户体验

### 历史记录管理
- **三大分类**: 全部、收藏、生词本，分标签页管理
- **差异化展示**: 
  - 全部：简洁列表，快速浏览
  - 收藏：卡片样式，展开查看详情
  - 生词本：按掌握程度分组，网格布局
- **详情对话框**: 点击列表项弹出完整信息，支持即时操作
- **一键操作**: 支持收藏、加入生词本、重新翻译、删除
- **智能清理**: 清空历史时自动保留收藏和生词本内容
- **本地存储**: 使用 SharedPreferences 持久化存储
- **实时更新**: StatefulBuilder 确保对话框状态即时刷新

### 生词本系统
- **智能验证**: 仅支持单个英文单词，句子和短语使用收藏功能
- **三级评分**: 
  - 未学习 (灰色)
  - 学习中 (橙色)
  - 已掌握 (绿色)
- **进度追踪**: 星级评分 + 进度条可视化学习状态
- **分组展示**: 按熟练度等级分组，紧凑网格布局
- **学习统计**: 总词数、已掌握、学习中、未学习四项数据
- **详情对话框**: 点击单词查看完整释义和操作选项

### 灵活配置
- **API 配置**: 支持自定义 API URL、密钥和模型
- **安全存储**: API 密钥使用 flutter_secure_storage 加密保存
- **配置管理**: 独立的设置界面，简洁易用

## 设计特色

### UI/UX 设计
- **Material Design 3**: 现代化设计语言
- **Tailwind Blue 主题**: #3B82F6 主色调，清爽专业
- **无 AppBar 设计**: 去除冗余标题栏，最大化内容空间
- **浅色背景**: #F6F8FB 舒适阅读背景
- **纯白卡片**: 层次分明，信息聚焦
- **渐变动画**: 流畅的淡入淡出效果
- **字体层级**: 音标、释义、例句分级显示
- **微妙色彩**: 翻译输出区使用 #FAFBFC 背景，区分输入区但不突兀

### 交互体验
- **即时反馈**: 按钮点击、状态切换即时显示
- **优雅动画**: 翻译结果 400ms 淡入，状态变化平滑过渡
- **响应式布局**: 适配不同屏幕尺寸
- **手势友好**: 下拉刷新、点击展开、长按操作

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: Provider 6.1.1
- **本地存储**: 
  - shared_preferences 2.2.2 (历史记录)
  - flutter_secure_storage 9.0.0 (API 密钥)
- **网络请求**: Dio 5.4.0
- **日期格式化**: intl 0.19.0
- **架构**: 分层架构 (Models → Services → Providers → UI)

## 项目结构

```
lib/
├── main.dart                           # 应用入口
├── models/
│   ├── api_config.dart                # API 配置模型
│   └── translation_history.dart       # 翻译历史模型
├── services/
│   ├── api_service.dart               # API 调用服务
│   └── storage_service.dart           # 本地存储服务
├── providers/
│   ├── translation_provider.dart      # 翻译状态管理
│   └── config_provider.dart           # 配置状态管理
├── screens/
│   ├── home_screen.dart               # 主页（翻译界面）
│   ├── history_screen.dart            # 历史记录界面（290行）
│   └── settings_screen.dart           # 设置界面
└── widgets/
    ├── language_selector.dart         # 语言选择器
    ├── translation_input.dart         # 翻译输入框
    ├── translation_output.dart        # 翻译结果显示
    └── history/                       # 历史记录组件模块（新）
        ├── history_list_item.dart     # 简洁列表项（78行）
        ├── history_card.dart          # 历史记录卡片（240行）
        ├── history_detail_dialog.dart # 历史详情对话框（235行）
        ├── mastery_indicator.dart     # 掌握程度指示器（95行）
        ├── vocabulary_statistics.dart # 生词本统计卡片（126行）
        ├── vocabulary_word_chip.dart  # 单词标签（38行）
        ├── vocabulary_mastery_group.dart # 掌握程度分组（97行）
        └── word_detail_dialog.dart    # 单词详情对话框（171行）
```

### 架构说明

- **分层架构**: Models → Services → Providers → UI
- **模块化设计**: 历史记录相关组件独立成 `widgets/history/` 模块
- **单一职责**: 每个文件只负责一个组件或功能
- **代码优化**: 主界面从 1199 行精简至 290 行，提升 76% 可维护性

## 快速开始

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd mini_translate
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

### 配置 API

首次运行需要在"设置"界面配置 AI API:

1. 点击底部导航栏的"设置"图标
2. 填写以下信息:
   - **API URL**: OpenAI 兼容的 API 地址
   - **API Key**: 您的 API 密钥
   - **模型名称**: 如 `gpt-3.5-turbo`
3. 点击"保存配置"

## 使用说明

### 翻译文本
1. 在"翻译"界面输入文本
2. 选择源语言和目标语言(或使用"自动"检测)
3. 点击"翻译"按钮
4. 查看翻译结果(单词会自动显示音标和例句)

### 管理历史
- **查看历史**: 切换到"历史"标签页
- **收藏**: 点击卡片上的星星图标
- **加入生词本**: 点击书本图标(仅限单个英文单词)
- **删除**: 长按或展开卡片后点击删除
- **清空**: 点击顶部删除图标(保留收藏和生词本)

### 使用生词本
1. 在"历史"界面切换到"生词本"标签
2. 查看学习统计和分组单词
3. 点击单词查看详细释义
4. 在详情弹窗中调整熟练度等级
5. 跟踪学习进度

## 特色亮点

### 智能区分
- **收藏**: 适用于任何翻译内容(句子、段落、单词)
- **生词本**: 专为英语单词学习设计，带熟练度追踪

### 用户体验优化
- 翻译结果淡入动画(400ms)
- 历史列表简洁设计，点击查看详情
- 对话框即时状态更新(StatefulBuilder)
- 生词本网格布局，一屏显示更多单词
- 错误提示在当前界面显示，避免混淆
- 清空历史保留重要内容

### 数据安全
- API 密钥加密存储(flutter_secure_storage)
- 本地数据持久化(shared_preferences)
- Release 版本支持网络请求(已配置 ProGuard)

### 代码质量
- **模块化架构**: 8 个独立历史组件，职责清晰
- **可维护性**: 主界面代码量减少 76%
- **可复用性**: 组件可独立使用和测试
- **零编译错误**: 通过 flutter analyze 检查

## 版本历史

### v0.0.2 (2025-10-29) - UI/UX 大更新
**UI 现代化**
- 重新设计翻译输入/输出区域，采用 Tailwind Blue 主题
- 输出区背景调整为极浅灰蓝(#FAFBFC)，区分输入但不突兀
- 翻译按钮添加蓝色光晕阴影，视觉焦点更明确
- 优化设置界面配置卡片，更加紧凑专业

**历史界面重构**
- "全部"标签：改用简洁列表，点击弹出详情对话框
- "收藏"标签：保留卡片设计，支持展开查看完整信息
- "生词本"标签：按掌握程度分组，网格布局
- 详情对话框支持即时状态更新(StatefulBuilder)
- 修复对话框交互后状态不更新的问题

**代码重构**
- 拆分 `history_screen.dart`：1199 行 → 290 行（减少 76%）
- 新建 `widgets/history/` 模块，包含 8 个独立组件
- 提升代码可维护性、可复用性、可测试性
- 通过 flutter analyze 零编译错误检查

### v0.0.1 (2025-10-28) - 首次发布
**核心功能**
- 基础翻译功能
- 历史记录管理
- 收藏功能
- 词典模式(音标+例句)
- 生词本系统(三级评分)
- 学习进度统计
- 自动语言检测
- Material Design 3 UI
- 淡入动画效果

**技术实现**
- Release 版本网络修复(添加 INTERNET 权限)
- ProGuard 配置优化(standard 模式)
- APK 体积优化(ABI 分包)

## 开发亮点

### 性能优化
- APK 体积：100MB+ → 14.7-18.3MB（按架构分包）
- 主界面代码：1199 行 → 290 行（提升 76% 可维护性）
- 组件化拆分：8 个独立模块，平均 38-240 行

### 工程实践
- **CI/CD**: GitHub Actions 自动构建和发布
- **代码质量**: 通过 flutter analyze 检查，零编译错误
- **安全性**: API 密钥加密存储，ProGuard 混淆保护
- **版本管理**: Git 标签管理，自动创建 Release

### 架构设计
- **分层架构**: Models → Services → Providers → UI
- **状态管理**: Provider 模式，响应式更新
- **模块化**: 独立组件，职责单一，易于测试
- **可扩展**: 支持添加新的翻译引擎和语言对

## 构建说明

### 开发构建
```bash
flutter run
```

### Release 构建
```bash
# 构建所有架构
flutter build apk --release

# 构建特定架构（推荐，减小体积）
flutter build apk --release --split-per-abi --target-platform android-arm64
```

### APK 文件
- `arm64-v8a`: 约 18.3 MB（推荐，现代设备）
- `armeabi-v7a`: 约 17.4 MB（旧设备）
- `x86_64`: 约 14.7 MB（模拟器）

## 许可证

本项目仅供学习交流使用。

## 贡献

欢迎提交 Issue 和 Pull Request!

## 联系方式

如有问题或建议，请通过 Issue 联系。
