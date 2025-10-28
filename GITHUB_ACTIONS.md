# GitHub Actions 自动构建 APK 指南

## 概述

本项目配置了两种自动构建方式:
1. **标准构建** (build-apk.yml) - 使用 GitHub Actions 的 Ubuntu 环境
2. **Docker 构建** (build-apk-docker.yml) - 在 Docker 容器中构建

## 方法一: 标准 GitHub Actions 构建 (推荐)

### 触发条件
- 推送到 `main` 或 `master` 分支
- 创建 `v*` 格式的 tag (如 v1.0.0)
- Pull Request 到 `main` 或 `master`
- 手动触发

### 功能特性
- ✅ 自动构建 3 个架构的 APK (armeabi-v7a, arm64-v8a, x86_64)
- ✅ 自动重命名 APK 文件 (包含版本号)
- ✅ 显示构建摘要和 APK 大小
- ✅ 上传构建产物 (保留 30 天)
- ✅ 创建 tag 时自动发布 Release

### 使用步骤

1. **推送代码到 GitHub**
```bash
git add .
git commit -m "Add GitHub Actions workflow"
git push origin main
```

2. **查看构建状态**
- 访问 GitHub 仓库 → Actions 标签页
- 查看 "Build APK" 工作流运行状态

3. **下载构建产物**
- 构建完成后，点击工作流运行记录
- 在 "Artifacts" 部分下载 `apk-release`

4. **发布正式版本** (可选)
```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```
- 自动创建 GitHub Release
- APK 文件自动附加到 Release

## 方法二: Docker 容器构建

### 触发条件
- 推送到 `docker-build` 分支
- 手动触发

### 本地 Docker 构建测试

1. **构建 Docker 镜像**
```bash
docker build -t mini-translate-builder .
```

2. **运行构建**
```bash
docker run --rm -v ${PWD}/build:/app/build mini-translate-builder
```

3. **提取 APK**
```bash
# APK 文件会在 build/app/outputs/flutter-apk/ 目录
```

### GitHub Actions Docker 构建

推送到 docker-build 分支:
```bash
git checkout -b docker-build
git push origin docker-build
```

## 自定义配置

### 修改 Flutter 版本

在 `.github/workflows/build-apk.yml` 中:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # 修改这里
    channel: 'stable'
```

### 修改构建目标

如果只需要单个通用 APK:
```yaml
- name: Build APK
  run: flutter build apk --release  # 去掉 --split-per-abi
```

### 添加签名配置 (推荐用于生产)

1. 生成签名密钥
```bash
keytool -genkey -v -keystore release.keystore -alias mini_translate -keyalg RSA -keysize 2048 -validity 10000
```

2. 将密钥文件 Base64 编码
```bash
base64 release.keystore > release.keystore.base64
```

3. 在 GitHub 仓库设置 Secrets:
   - `KEYSTORE_BASE64`: 上面生成的 base64 内容
   - `KEYSTORE_PASSWORD`: 密钥库密码
   - `KEY_ALIAS`: mini_translate
   - `KEY_PASSWORD`: 密钥密码

4. 修改工作流添加签名步骤:
```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release.keystore

- name: Create key.properties
  run: |
    cat > android/key.properties << EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=release.keystore
    EOF
```

## 工作流文件说明

### build-apk.yml (标准构建)
- 使用 Ubuntu 最新版本
- 安装 Java 17 和 Flutter 3.24.0
- 分架构构建 APK
- 自动版本号命名
- 上传构建产物和创建 Release

### build-apk-docker.yml (Docker 构建)
- 使用 Cirrus Labs 的官方 Flutter Docker 镜像
- 包含完整的 Flutter SDK 和 Android SDK
- 适合需要完全隔离的构建环境

## 常见问题

### Q: 构建失败怎么办？
A: 查看 Actions 日志，常见问题:
- 依赖版本不兼容
- Gradle 构建超时 (GitHub Actions 有 6 小时限制)
- 代码分析错误 (已设置 continue-on-error)

### Q: 如何加速构建？
A: 
1. 启用缓存 (已配置 `cache: true`)
2. 减少依赖包
3. 使用预构建的 Docker 镜像

### Q: APK 在哪里下载？
A: 
- 每次构建: Actions → 工作流运行 → Artifacts
- Tag 构建: Releases 页面

### Q: 如何手动触发构建？
A: GitHub 仓库 → Actions → 选择工作流 → Run workflow

## 本地测试工作流

安装 act (GitHub Actions 本地运行工具):
```bash
# Windows (使用 Chocolatey)
choco install act-cli

# 或使用 Scoop
scoop install act
```

运行工作流:
```bash
act -j build
```

## 构建优化建议

1. **缓存优化**: 已启用 Flutter pub 缓存
2. **并行构建**: 考虑分离不同架构到独立 job
3. **增量构建**: 对于频繁构建，考虑使用 cache layers
4. **构建通知**: 添加 Slack/Email 通知

## 参考资源

- [Flutter GitHub Actions](https://github.com/subosito/flutter-action)
- [Cirrus Labs Docker Images](https://github.com/cirruslabs/docker-images-flutter)
- [GitHub Actions 文档](https://docs.github.com/actions)
