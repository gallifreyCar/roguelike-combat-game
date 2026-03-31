#!/bin/bash
# tools/package.sh - Blood Cards 打包脚本
# 用法: ./tools/package.sh [platform]
# platform: mac, win, love, all

VERSION="1.0.0"
GAME_NAME="blood_cards"
PROJECT_DIR="/Users/gallifreycar/Documents/roguelike-game"
OUTPUT_DIR="$PROJECT_DIR/dist"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 创建 .love 文件
create_love_file() {
    echo "Creating $GAME_NAME v$VERSION .love file..."
    cd "$PROJECT_DIR"
    zip -r "$OUTPUT_DIR/$GAME_NAME_v$VERSION.love" . \
        -x "*.git*" \
        -x "*.DS_Store" \
        -x "*dist/*" \
        -x "*tools/*" \
        -x "*.love" \
        -x "*save/*"
    echo "Created: $OUTPUT_DIR/$GAME_NAME_v$VERSION.love"
}

# macOS 打包
package_mac() {
    echo "Packaging for macOS..."
    LOVE_APP="/Applications/love.app"

    if [ ! -d "$LOVE_APP" ]; then
        echo "Error: LÖVE app not found at $LOVE_APP"
        echo "Please install LÖVE 11.5: brew install love"
        return 1
    fi

    create_love_file

    # 合并到 macOS 应用
    cd "$OUTPUT_DIR"
    cat "$LOVE_APP/Contents/MacOS/love" "$GAME_NAME_v$VERSION.love" > "$GAME_NAME_mac_v$VERSION"
    chmod +x "$GAME_NAME_mac_v$VERSION"

    echo "Created: $OUTPUT_DIR/$GAME_NAME_mac_v$VERSION"
    echo "Run with: $OUTPUT_DIR/$GAME_NAME_mac_v$VERSION"
}

# Windows 打包（需要 Windows 版 LÖVE）
package_win() {
    echo "Packaging for Windows..."
    echo "Note: This requires Windows version of LÖVE"
    create_love_file

    echo "On Windows, run:"
    echo "copy /b love.exe+$GAME_NAME_v$VERSION.love $GAME_NAME.exe"
}

# 主入口
case "$1" in
    "mac")
        package_mac
        ;;
    "win")
        package_win
        ;;
    "love")
        create_love_file
        ;;
    "all")
        package_mac
        package_win
        ;;
    *)
        echo "Blood Cards Package Tool"
        echo "Usage: $0 [platform]"
        echo "Platforms: mac, win, love, all"
        echo ""
        create_love_file
        ;;
esac

echo ""
echo "Package complete!"
echo "Files in: $OUTPUT_DIR"