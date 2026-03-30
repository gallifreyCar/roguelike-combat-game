# 字体文件说明

## 中文字体配置

本项目需要中文字体支持。由于字体文件较大，不包含在 Git 仓库中。

### macOS 用户

运行以下命令复制系统自带的中文字体：

```bash
cp "/System/Library/Fonts/STHeiti Light.ttc" /Users/gallifreycar/Documents/roguelike-game/assets/fonts/
```

或者手动复制：
1. 打开 Finder
2. 按 Cmd+Shift+G，输入 `/System/Library/Fonts/`
3. 找到 `STHeiti Light.ttc` 文件
4. 复制到 `assets/fonts/` 目录

### Windows 用户

复制 `C:\Windows\Fonts\msyh.ttc`（微软雅黑）到 `assets/fonts/` 目录。

### Linux 用户

```bash
# Ubuntu/Debian
sudo apt install fonts-noto-cjk
cp /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc assets/fonts/STHeiti\ Light.ttc
```

### 下载 Noto Sans SC

如果系统没有中文字体，可以从以下地址下载：
- Google Fonts: https://fonts.google.com/noto/specimen/Noto+Sans+SC
- GitHub: https://github.com/googlefonts/noto-cjk

下载后重命名为 `STHeiti Light.ttc` 放入此目录。
