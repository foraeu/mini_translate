# Flutter移动端翻译App开发需求

## 项目概述
请帮我开发一个Android端的翻译应用,使用Flutter框架,具有现代化的UI设计和完整的功能。

## 核心功能需求

### 1. 大模型配置管理
需要一个配置页面,允许用户设置以下参数:
- **大模型名称**: 文本输入框,用于显示(如"GPT-4翻译", "Claude翻译"等)
- **API URL**: 文本输入框,支持完整的API端点地址
- **Model名称**: 文本输入框或下拉选择(如 gpt-4, claude-3-sonnet, qwen-turbo等)
- **API Key**: 加密输入框(输入时显示为圆点或星号),支持显示/隐藏切换

配置需要:
- 本地持久化存储(使用shared_preferences或secure_storage)
- 支持保存多个配置并快速切换
- 配置验证功能(测试连接是否可用)

### 2. 翻译核心功能
- **输入区域**: 多行文本输入框,支持:
  - 清除按钮
  - 字数统计
  - 粘贴快捷操作
- **输出区域**: 显示翻译结果,支持:
  - 复制按钮
  - 一键复制全部
  - 翻译历史记录
- **语言选择**:
  - 源语言选择(支持自动检测)
  - 目标语言选择
  - 快速切换源语言和目标语言的按钮
- **翻译按钮**: 醒目的主操作按钮,带加载状态

### 3. API调用实现
- 使用http或dio库调用大模型API
- 支持标准的OpenAI格式API调用
- 实现以下prompt模板:
```
请将以下文本从{源语言}翻译成{目标语言},保持原意和语气:

{待翻译文本}
```
- 错误处理:网络错误、API错误、超时等
- 加载状态显示(骨架屏或加载动画)

### 4. UI/UX设计要求
采用现代Material Design 3风格:
- **配色方案**:
  - 使用动态主题色或自定义渐变色
  - 深色模式支持
- **动画效果**:
  - 页面切换动画
  - 按钮点击反馈
  - 翻译结果淡入效果
- **布局**:
  - 底部导航栏(翻译页/历史页/设置页)
  - 响应式设计,适配不同屏幕尺寸
  - 合理的间距和圆角设计

### 5. 附加功能
- **翻译历史**: 本地保存最近的翻译记录,支持查看和重新翻译
- **收藏功能**: 收藏常用翻译结果
- **复制提示**: Toast或Snackbar反馈

## 技术栈要求
- **框架**: Flutter 3.x
- **状态管理**: Provider 或 Riverpod
- **网络请求**: dio
- **本地存储**: shared_preferences + flutter_secure_storage
- **UI组件**: Material 3

## 代码结构建议
```
lib/
├── main.dart
├── models/
│   ├── api_config.dart          # API配置模型
│   └── translation_history.dart # 翻译历史模型
├── services/
│   ├── api_service.dart         # API调用服务
│   └── storage_service.dart     # 本地存储服务
├── providers/
│   ├── config_provider.dart     # 配置状态管理
│   └── translation_provider.dart # 翻译状态管理
├── screens/
│   ├── home_screen.dart         # 主翻译页面
│   ├── history_screen.dart      # 历史记录页面
│   └── settings_screen.dart     # 设置页面
└── widgets/
    ├── language_selector.dart   # 语言选择组件
    ├── translation_input.dart   # 输入组件
    └── translation_output.dart  # 输出组件
```

## 开发步骤建议
1. 首先搭建项目基础结构和导航框架
2. 实现配置管理和本地存储
3. 开发API调用服务
4. 实现翻译核心功能
5. 完善UI和动画效果
6. 添加历史记录和收藏功能
7. 测试和优化

## 输出要求
- 提供完整可运行的代码
- 代码包含详细注释
- 关键功能提供使用说明
- 如果代码较长,可以分模块提供

请从第一步开始,帮我实现这个应用。
