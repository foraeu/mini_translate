FROM ghcr.io/cirruslabs/flutter:stable

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 获取依赖
RUN flutter pub get

# 分析代码
RUN flutter analyze || true

# 构建 APK
RUN flutter build apk --release --split-per-abi

# 输出构建信息
RUN ls -lh build/app/outputs/flutter-apk/

# 默认命令
CMD ["sh"]
