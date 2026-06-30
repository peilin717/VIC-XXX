#!/bin/bash

# 1. 启动虚拟显示器
Xvfb :1 -screen 0 1280x960x24 &
export DISPLAY=:1

# 2. 启动 VNC 服务 (去掉了引发冲突的 fluxbox)
x11vnc -forever -shared -rfbport 5900 -display :1 -nopw -quiet &

# 3. 启动 noVNC (将输出重定向，避免日志太脏)
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &

# 4. 多等一秒，确保 Xvfb 完全初始化完成
sleep 3

# 5. 注入防崩溃环境变量，并启动 C++ 程序
echo "Starting Gomoku Benchmark..."
export SDL_VIDEO_X11_REQUIRE_WM=0  # 告诉 SDL2 当前没有窗口管理器，不要乱抢焦点
cd /app/build
./gomoku_benchmark

# 6. 兜底挂起命令，方便后续万一再崩溃时进容器查日志
tail -f /dev/null