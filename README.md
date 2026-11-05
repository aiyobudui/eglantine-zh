# Eglantine 中文汉化版（覆盖包）

## 这是什么

Eglantine 是一款 Nintendo Switch 2 模拟器，基于 Eden / Yuzu / Sudachi 分支开发（开发者 Djihads80，GitHub：`Djihads80/Eglantine`，默认分支 `nx2`）。

官方发布的 Windows 版（build-212，MSVC 编译，Qt 6.8.3）界面虽支持多语言，但其可执行文件内嵌的 Qt 翻译资源 `:/languages/` **是空的**——官方发布包里根本没有附带任何 `.qm` 翻译文件。而加载器只从编译进 exe 的资源读取翻译，**没有磁盘回退目录**，所以无论怎么改设置，界面都会回退为英文。

本仓库提供一套**中文汉化覆盖文件**。覆盖到官方版本目录后即可获得简体中文界面，并可通过 Git 分发与同步。

## 包含内容

| 文件 / 目录 | 作用 |
| --- | --- |
| `Game/eglantine.exe` | 已打补丁的主程序：翻译加载路径从内置资源 `:/languages/` 改为等长的磁盘相对路径 `./languages/` |
| `Game/languages/zh_CN.qm` | 简体中文翻译包，**2864 条成品**：应用界面约 1930 条 + Qt 框架控件 934 条（确定/取消/文件对话框等） |
| `Game/languages/zh-CN.qm` | 同一文件的连字符命名版，兼容不同加载方式 |
| `Game/portable.txt` | 启用便携模式：配置写入 `Game/user/config/`，便于携带 |
| `Game/user/config/qt-config.ini.zh-CN.example` | **脱敏的中文 + 相对路径配置模板**，仅在新环境且尚无 `qt-config.ini` 时使用 |
| `启动模拟器.bat` | **推荐启动方式**：把工作目录锁定为 `Game/`，保证中文语言包与相对游戏目录都能解析 |
| `README.md` / `.gitignore` | 说明与忽略规则 |

> 仓库**不含**模拟器运行时（Qt6 等 DLL、插件）、游戏 ROM、密钥、固件，也不含真实的 `qt-config.ini`（其中有 `eden_token` 等敏感信息）。`room/` 目录已被忽略。

## 使用方法

1. 先从官方渠道获取 Eglantine（build-212 或相近版本）并解压，得到 `eglantine-windows-x86_64/Game/` 及运行时（Qt6、依赖 DLL、插件目录）。
2. 把本仓库内容**覆盖**到该 `eglantine-windows-x86_64/` 目录（保持 `Game/` 结构不变）。
3. **中文界面**：
   - 中文系统下通常自动生效（加载器会先用 `QLocale()` 找 `./languages/zh_CN.qm`）；
   - 若仍为英文，且该目录**还没有** `Game/user/config/qt-config.ini`，把 `qt-config.ini.zh-CN.example` 复制并改名为 `qt-config.ini`；
   - 若已有自己的 `qt-config.ini`，**不要覆盖**，直接在「设置 → 界面 → 语言」选择简体中文即可。
4. **推荐双击根目录的 `启动模拟器.bat`** 启动（它会把工作目录锁定为 `Game/`）。也可直接双击 `Game/eglantine.exe`；若用快捷方式，必须把「起始位置」设为 `Game/`——**工作目录不对时，中文语言包和相对游戏目录都会失效**。
5. **游戏内中文**：模板里 `language_index=15`（简体中文）、`region_index=4`（中国）。

> ⚠️ 游戏 ROM、密钥、固件不在仓库内。密钥放 `Game/user/keys/prod.keys`、`title.keys`；固件 NCA 放 `Game/user/nand/system/Contents/registered/`。**密钥版本必须与固件版本匹配**（例如 22.5.0 密钥不能配 23.0.1 固件，否则日志会刷 `keys for gen 0x17+ required`）。

## 可移植路径（打包给别人直接能玩）

配置里的路径**全部是相对路径**，基准为工作目录 `Game/`：

| 配置项 | 值 | 指向 |
| --- | --- | --- |
| `Paths\gamedirs\4\path` | `../room` | 与 `Game/` 同级的游戏目录 |
| `Screenshots\screenshot_path` | `user/screenshots` | 截图 |
| `nand_directory` / `sdmc_directory` / `load_directory` / `dump_directory` / `tas_directory` | `user/nand` 等 | 固件、密钥、存档 |
| `Paths\recentFiles` | `../room/exefs/main` | 最近打开的游戏 |

因此把整个 `eglantine-windows-x86_64/` 目录拷到**任何盘符、任何路径**，玩家用 `启动模拟器.bat` 打开就能直接看到游戏列表，**无需手动点「添加游戏目录」**。

要求与调整：

- 目录结构必须是 `eglantine-windows-x86_64/Game/` + `eglantine-windows-x86_64/room/`（游戏数据与 `Game/` 同级）。
- **`room/` 不在仓库内**（约 25 万个松散文件），需单独拷贝；密钥与固件同理，见上方说明。
- 若游戏目录改名或移动，只需改 `Paths\gamedirs\4\path` 一行。
- 新机器若还没有 `qt-config.ini`，把 `qt-config.ini.zh-CN.example` 复制并改名即可——模板本身已采用相对路径。
- 已验证：模拟器启动时会 `WriteToIni` 写回配置，**相对路径会被原样保留**，不会规范化成绝对路径。

## 工作原理

官方加载器（`src/yuzu/main_window.cpp`）里的调用是：

```cpp
translator.load(QLocale(), {}, {}, QStringLiteral(":/languages/"));
translator.load(UISettings::values.language, QStringLiteral(":/languages/"));
```

只认 exe 内嵌资源。本方案：

- **等长原地补丁**：把两处 `QStringLiteral` 字符串改为 `./languages/`（12 字符，对应原 `:/languages/`）和 `./languages`（11 字符，对应原 `:/languages`）。**必须等长**——`QStringLiteral` 在编译期把长度写死在数据头里，长度不匹配会让字符串带错误长度/嵌入空字符，补丁静默失效（本项目踩过这个坑）。PE 头与文件大小均不变。
- **合并翻译包**：把应用 `zh_CN.ts` 与 Qt 框架 `qtbase_zh_CN.qm`（934 条）在 `.ts` 层合并后用官方 `lrelease` 编译，使一次加载即可覆盖应用界面与 Qt 标准控件。
  > ⚠️ 合并脚本解析 `.ts` 时**必须先做 XML 反转义**（`&amp;`→`&`、`&quot;`→`"`）。否则 `<source>&amp;File</source>` 会被当成字面量 `&amp;File`，与 exe 中真实的 `&File` 永久失配——症状是游戏列表等不含 `&` 的部分正常中文，而顶部菜单 `File/Emulation/View/Tools/Multiplayer/Help` 始终英文（本项目踩过这个坑）。
- **配置**：`[UI] Paths\language=zh-CN`（并置 `\default=false` 防止被重置），`first_launch=false`。

原始未打补丁的 exe 备份为 `Game/eglantine.exe.preZhPatch.bak`（不在仓库内），供还原用。

## 同步与更新

```bash
git pull
```

拉取最新汉化覆盖文件后用 `启动模拟器.bat` 重新启动即可。新机器先解压官方包，再 `git clone` 覆盖。

> 注意：真实的 `Game/user/config/qt-config.ini` 不入库（含机器相关设置与 `eden_token`），`git pull` **不会**覆盖你本机的路径与中文设置。

## 已知问题（与汉化无关）

- **加载游戏约 20 秒**：游戏是解包的松散 RomFS（`room/romfs/` 约 25 万个文件），日志显示 `Loose RomFS image ready: elapsed_ms=19638`，即近 19.6 秒花在枚举这些文件上。已建议为整个目录添加 Windows Defender 排除项；要根本提速需把 RomFS 重新打包成镜像（目前缺乏可用于 Switch 2 游戏的工具链）。
- **部分 Switch 2 游戏无法正常运行**：Eglantine 属开发版，日志中会出现 `nx2:IApplicationProxy` 等未实现服务的 `Critical` 断言及 `Unmapped Device ReadBlock`，属模拟器兼容性限制，非本汉化包问题。

## 还原为官方版

把 `Game/eglantine.exe.preZhPatch.bak` 重命名回 `eglantine.exe`（或直接从官方包重新解压），并删除 `Game/languages/` 目录即可。

---

*本仓库仅提供界面汉化覆盖文件，不含模拟器源码、游戏 ROM 或任天堂专有密钥，请遵守你所在地区的相关法律法规。*
