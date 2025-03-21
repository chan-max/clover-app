#!/bin/bash

# 配置项
SERVER_USER="root"  # 服务器用户名
SERVER_IP="49.232.186.238"  # 服务器 IP 地址
SERVER_PASSWORD="666666z"  # 服务器密码
SERVER_FOLDER="/www/wwwroot/thelawofattraction.cn"  # 服务器目标文件夹

# 进入脚本所在目录（Flutter 项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "无法进入项目目录"; exit 1; }

# 清理并获取依赖
echo "正在获取 Flutter 依赖..."
flutter pub get

# 构建 Flutter Web 项目
echo "正在构建 Flutter Web 项目..."
flutter build web

# 检查构建输出目录是否存在
BUILD_OUTPUT_PATH="build/web"
if [ ! -d "$BUILD_OUTPUT_PATH" ]; then
  echo "构建输出目录未找到，请检查路径: $BUILD_OUTPUT_PATH"
  exit 1
fi

# 上传构建文件到服务器
echo "正在上传文件到服务器..."
sshpass -p "$SERVER_PASSWORD" scp -r "$BUILD_OUTPUT_PATH"/* "$SERVER_USER@$SERVER_IP:$SERVER_FOLDER"

# 检查上传是否成功
if [ $? -eq 0 ]; then
  echo "文件上传成功！"
else
  echo "文件上传失败，请检查网络或服务器配置。"
  exit 1
fi