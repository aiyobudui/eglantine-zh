# Eglantine 中文汉化版（覆盖包）

## 这是什么

Eglantine 是一款 Nintendo Switch 2 模拟器，基于 Eden / Yuzu / Sudachi 分支开发（开发者 Djihads80，GitHub：`Djihads80/Eglantine`，默认分支 `nx2`）。

官方发布的 Windows 版（build-212，MSVC 编译）界面虽然支持多语言，但其可执行文件内嵌的 Qt 翻译资源 `:/languages/` **为空**，导致无论怎么改设置，界面都会回退为英文。

本仓库提供一套**中文汉化覆盖文件**。将其覆盖到你已有的官方版本目录后，即可获得完整、稳定的简体中文界面，且方便通过 Git 分发与同步。

## 包含内容

| 文件 / 目录 | 作用 |
| --- | --- |
| `Game/eglantine.exe` | 已打补丁的模拟器主程序（翻译加载路径从内置资源改为磁盘目录 `languages/`） |
| `Game/languages/zh_CN.qm` | 简体中文翻译包（由官方 `zh_CN.ts` 编译，共 1936 条） |
| `Game/languages/zh-CN.qm` | 同上内容的连字符命名版，兼容不同加载方式 |
| `Game/portable.txt` | 启用便携模式（配置写入 `Game/user/config/`，便于携带与覆盖） |
| `Game/user/config/qt-config.ini` | 已设置简体中文的配置文件 |
| `README.md` | 本说明 |

> 仓库**不含**模拟器运行时（Qt6 等依赖库）、游戏 ROM、密钥。`room/` 目录已被忽略，请自行准备。

## 使用方法

1. 先从官方渠道获取 Eglantine（build-212 或相近版本）并解压，得到 `eglantine-windows-x86_64/Game/` 目录及运行时（Qt6、依赖 DLL、插件目录等）。
2. 将本仓库的内容**覆盖**到该 `eglantine-windows-x86_64/` 目录（保持 `Game/` 路径结构不变）。
3. 通过**双击 `Game/eglantine.exe`** 启动（工作目录须为 `Game/`，便携模式与相对翻译路径才能正确解析）。
4. 界面即为简体中文。

> ⚠️ 游戏 ROM / 密钥不在本仓库内，请自行准备并放置于 `room/` 目录（默认忽略，不会入库）。

## 工作原理（简述）

官方加载器仅从编译进 exe 的 Qt 资源 `:/languages/` 读取翻译，且无文件系统回退。本方案：

- 对 `eglantine.exe` 内部两处翻译路径字符串 `:/languages/` 原地改写为磁盘相对路径 `languages/`（PE 头完好，文件大小不变）；
- 将 `zh_CN.qm` 放入 `Game/languages/`；
- 把配置键 `[UI] Paths\language` 设为 `zh-CN`，并将 `first_launch` 置为 `false` 防止首次向导覆盖语言设置。

原始未打补丁的 exe 已单独备份为 `Game/eglantine.exe.preZhPatch.bak`（不在本仓库内），供需要时还原。

## 同步与更新

在你本地的 `eglantine-windows-x86_64/` 目录执行：

```bash
git pull
```

拉取最新汉化覆盖文件后，重新双击 `Game/eglantine.exe` 即可。若需在一台新机器上使用，先解压官方包，再把本仓库文件覆盖过去。

## 还原为官方英文版

将 `Game/eglantine.exe.preZhPatch.bak` 重命名为 `eglantine.exe` 即可（如需纯净官方版，建议直接从官方包重新解压）。

---

*本仓库仅提供界面汉化覆盖文件，不含模拟器源码、游戏 ROM 或任天堂专有密钥，请遵守你所在地区的相关法律法规。*
