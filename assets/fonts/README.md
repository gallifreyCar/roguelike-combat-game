# 字体文件说明

## ⚠️ 关于版权（重要）

**推荐使用思源黑体 (Noto Sans SC / Source Han Sans)**：
- ✅ 由 Google 和 Adobe 联合开发
- ✅ 开源协议：SIL Open Font License 1.1
- ✅ **免费可商用**，无需付费
- ✅ 可以修改和再分发

**❌ 不要使用的字体**：
- STHeiti、PingFang SC → 苹果公司版权
- 微软雅黑 (msyh) → 微软版权
- 宋体、黑体 → 中易字库，商业使用需授权

---

## 手动下载思源黑体

### 方法1: 浏览器直接下载（推荐）

打开浏览器访问：

1. **Google Fonts 官方**：
   https://fonts.google.com/noto/specimen/Noto+Sans+SC
   点击右上角 **"Download family"** 按钮

2. **GitHub Releases**：
   https://github.com/googlefonts/noto-cjk/releases
   找到最新版本，下载 `NotoSansSC-Regular.otf`

### 方法2: Adobe 官方

https://github.com/adobe-fonts/source-han-sans/releases
下载 `SourceHanSansSC-Regular.otf`（与 Noto Sans SC 相同）

### 方法3: Homebrew（macOS）

```bash
brew tap homebrew/cask-fonts
brew install --cask font-noto-sans-sc
# 然后复制：
cp ~/Library/Fonts/NotoSansSC-Regular.otf assets/fonts/
```

---

## 下载后配置

1. 将下载的字体文件重命名为 `NotoSansSC-Regular.otf`
2. 放入 `assets/fonts/` 目录
3. 重新运行游戏

```
assets/fonts/
└── NotoSansSC-Regular.otf   # 思源黑体简体中文
```

---

## 许可证信息

思源黑体使用 SIL Open Font License 1.1：
- ✅ 免费使用
- ✅ 商业项目可用
- ✅ 可以修改和再分发
- ⚠️ 需保留原始版权声明

完整许可：https://scripts.sil.org/OFL