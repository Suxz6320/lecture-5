# 进度报告5（第7周·Flutter工程结构与Widget体系）

- 姓名：李桐　学号：20251060003
- 仓库地址：https://github.com/Suxz6320/lecture-5.git

## 一、任务理解

本次作业要完成三件事：① 跟随课堂案例复现 counter_deep——用 `flutter create` 生成默认计数器并精读 `lib/main.dart`，手绘完整 Widget 树（MaterialApp→Scaffold→各分支到叶子，标注 Stateless/Stateful），再完成两项改造（步长调节＋teal 主题；生命周期日志＋自定义图片资源），每个步骤独立 Git 提交；② 自主实践五项基本要求（Widget 树手绘图、生命周期日志、主题定制、资源替换、AI 使用标注）；③ 按十节模板填写本报告并存入仓库。
验收标准：计数器改造功能正确（步长 1/2/5 可选、点击 FAB 按步长累加）；teal 主题生效且至少两处 `Theme.of(context)` 取用；生命周期钩子日志齐全并能对照 r/R 行为；图片资源正常显示；仓库 3 次以上规范提交；能口头解释"点 FAB 后发生了什么"（setState→标记 dirty→下一帧重建）。

## 二、环境与工具

- 操作系统：Windows 11（24H2，26100.7840）
- Flutter 3.47.4 stable（D:\FLutter），Dart 3.13.3，DevTools 2.60.0
- 运行目标：Chrome 148（Web 调试模式）。**未选 Windows 桌面**：本机未安装 Visual Studio 工具链（见第六节），`flutter doctor` 中 Chrome 设备可用，故以 Web 方式运行
- Git 2.55.0；GitHub 远程仓库 lecture-5
- AI 工具：TraeCode（TraeWork 辅助复现＋手工改造）
- 绘图工具：mermaid.live（handDrawn 手绘风格，Widget 树图源文件见 docs/widget-tree.mmd）

## 三、过程记录

| 时间 | 操作 | 结果 |
|---|---|---|
| T0 | `flutter doctor -v` 检查环境 | Flutter/Chrome 可用；Visual Studio 未安装 |
| T1 | `flutter create . --project-name counter_deep --platforms windows,web` | 工程生成，入口 lib/main.dart |
| T2 | `git init` 并首次提交 `chore: flutter create counter_deep` | 仓库初始化 |
| T3 | 通读 main.dart，在 mermaid.live 手绘完整 Widget 树并标注两类 Widget | docs/widget-tree.png；提交 `docs: widget tree diagram` |
| T4 | 改造一：新增 `_step` 与 AppBar 弹层（步长 1/2/5）、body 增加步长显示；主题改 teal 种子色并定制标题字体 | `flutter analyze` 无问题；提交 `feat: step control & teal theme` |
| T5 | 改造二：五个生命周期钩子各加一行 print；自制 banner.png 放入 assets/images/，pubspec 声明，AppBar flexibleSpace 引用 | 提交 `feat: lifecycle logs & asset image` |
| T6 | `flutter run -d windows` 失败（缺 VS 工具链）→ 改 `flutter run -d chrome` | 应用正常启动，banner 正常显示 |
| T7 | 验证：点 FAB 计数累加；弹层选步长 5 后点击由 2 变 7；按 r/R 对照生命周期；`flutter test` 通过 | 全部符合预期 |
| T8 | 截图归档（docs/screenshots/），提交 `docs: run & lifecycle evidence screenshots`，撰写报告并推送 | 完成 |

## 四、关键代码

### ① setState 链路与步长（AI 生成，本人逐行核对并运行验证）

```dart
int _counter = 0;
int _step = 1; // 步长：每次点击 FAB 增加的值

void _incrementCounter() {
  setState(() {
    _counter += _step;   // 只改数据，不做耗时操作
  });
}

void _selectStep(int value) {
  setState(() => _step = value); // 弹层选择 1/2/5 同样走 setState
}
```

逐行解释：`_counter` 与 `_step` 是 State 持有的可变数据；点击 FAB 触发 `_incrementCounter`，`setState` 把"改数据"包起来通知框架该 State 已 dirty；框架在下一帧重新调用本 State 的 `build`，界面随新状态重建（UI = f(state)）。验证：运行后日志出现 `build: 重建界面 (counter=7, step=5)`，界面同步更新。

### ② 主题定制与两处 Theme.of 取用（AI 生成，本人对照指南验证）

```dart
// MaterialApp 中：种子色 deepPurple → teal，并定制字体样式
theme: ThemeData(
  colorScheme: .fromSeed(seedColor: Colors.teal),
  useMaterial3: true,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
  ),
),
// 取用①：AppBar 背景取主题 inversePrimary
backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// 取用②：计数数字取主题 headlineMedium（含定制的字重/字距）
style: Theme.of(context).textTheme.headlineMedium,
```

逐行解释：`ColorScheme.fromSeed` 由一粒种子色派生整套配色，`useMaterial3` 启用 M3 规范；页面里不写死颜色，而是用 `Theme.of(context)` 向上查找主题——改一处种子色，AppBar、FAB、水波纹全部同步，体现"样式与结构分离"。验证：界面 AppBar/FAB 呈 teal 色系（见截图）。

### ③ 生命周期日志与图片资源（AI 生成，运行日志验证）

```dart
@override
void initState() { super.initState(); print('[lifecycle] initState: 一次性初始化'); }
@override
void didChangeDependencies() { super.didChangeDependencies(); print('[lifecycle] didChangeDependencies: 依赖（如主题）就绪/变化'); }
@override
void didUpdateWidget(covariant MyHomePage oldWidget) { super.didUpdateWidget(oldWidget); print('[lifecycle] didUpdateWidget: 父级重建传入新配置'); }
@override
void dispose() { print('[lifecycle] dispose: 销毁清理'); super.dispose(); }
// build 内：print('[lifecycle] build: 重建界面 (counter=$_counter, step=$_step)')
// AppBar 中引用资源：flexibleSpace: Image.asset('assets/images/banner.png', fit: BoxFit.cover)
```

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
```

逐行解释：五个钩子覆盖 State 从创建到销毁的完整链路；`build` 可多次执行，其余钩子在特定时机触发。图片资源必须先在 pubspec 的 `flutter.assets` 段声明目录，`Image.asset` 才能读取，且**声明后必须完整重启**（热重载不注册新资源）。验证：启动日志顺序为 initState→didChangeDependencies→build；AppBar 背景图正常显示（见截图）。

## 五、检查点结果

| 检查点 | 结果 | 证据 |
|---|---|---|
| 步长功能正确（1/2/5 弹层可选，按步长累加） | ✅ | 截图 03（弹层）、04（步长 5 时 2→7）；日志 `counter=2, step=5 → counter=7, step=5` |
| teal 主题＋至少两处 Theme.of 取用 | ✅ | 截图 02/04（teal 色系）；代码第四.②节 |
| 生命周期日志齐全，r/R 行为对照 | ✅ | 见下方对照表；截图 05；docs/lifecycle-log.txt |
| 图片资源正常显示 | ✅ | 各截图中 AppBar 的 "Counter Deep" 背景图（assets/images/banner.png） |
| Widget 树手绘图（完整层级＋两类标注） | ✅ | docs/widget-tree.png（mermaid.live 手绘风格渲染） |
| 能口头解释 setState 链路 | ✅ | 点 FAB → `_incrementCounter` → `setState(() => _counter += _step)` → 框架将该 State 标记 dirty → 下一帧重新执行 `build` → 新界面上屏 |

**r/R 行为对照记录**（作业要求的标准动作）：

| 操作 | 日志表现 | 结论 |
|---|---|---|
| 冷启动 | initState → didChangeDependencies → build (counter=0) | State 创建走完整初始化序列 |
| 按 r（热重载） | 仅 build 重新执行，counter 保持原值 | 热重载**保持 State**，所以改样式用 r |
| 按 R（热重启） | initState → didChangeDependencies → build，counter 重置为 0 | 热重启**重置 State**，所以改初始化逻辑用 R |
| didUpdateWidget | 本次未触发 | 父级 MyApp 没有重建传入新配置 |
| dispose | `flutter test` 拆解和退出时打印 | 销毁阶段钩子正常 |

## 六、问题与调试

1. **`flutter run -d windows` 报错 "Unable to find suitable Visual Studio toolchain"**：定位过程——重读报错后运行 `flutter doctor -v`，确认 Visual Studio 一行红叉（未安装），而 Chrome 设备绿灯。解决：改用 `flutter run -d chrome` 运行，启动链路代码不受影响（调试目标只影响产物平台）。
2. **新增图片资源后界面不显示**：按指南翻车警告，资源声明只改 pubspec 不够，热重载不会注册新资源；完整重启（R / 重新 flutter run）后 `Image.asset` 正常加载，未出现 "Unable to load asset"。
3. **改造后担心默认 widget_test 失效**：步长功能上线后运行 `flutter test` 验证——默认测试点一次 FAB 期望 +1，由于 `_step` 默认值为 1，行为与模板一致，`All tests passed!`。

## 七、AI 使用记录

全程使用 TraeCode 辅助，遵循"先自己猜、再让 AI 给对照方案、比较差异"的动作：

| 用途 | 指令摘要 | AI 输出 | 本人验证方式 |
|---|---|---|---|
| Widget 树手绘图 | "按课堂案例复现手绘 Widget 树，MaterialApp→Scaffold→各分支到叶子，标注两类 Widget" | Mermaid 图源码（handDrawn 风格） | 浏览器实测渲染通过；对照默认 main.dart 逐节点核对；类型标注对照 api.flutter.dev 继承链核实（MaterialApp/Scaffold/AppBar 内部为 Stateful，FAB/Text/Icon 为 Stateless） |
| 步长与主题改造 | "增加步长调节（弹层 1/2/5），主题色改 teal 种子色" | 改造方案与代码 | 与我的猜想对照（见下表）；`flutter analyze` 无问题；运行后实际点击验证 |
| 生命周期日志 | "为 State 加生命周期日志，每个钩子一行 print" | 五个钩子的 print 代码 | 运行后按 r/R 各一次，输出顺序抄录（第五.对照表） |
| 资源替换 | "assets 放自定义图片作 AppBar 背景，pubspec 声明并重启验证" | banner.png 生成＋引用代码 | 完整重启后背景图显示成功 |
| 运行与证据采集 | "运行应用并截取整个电脑屏幕" | 后台运行＋日志采集脚本 | 逐张核对截图内容（功能、数值、日志一致） |

**猜想 vs AI 方案差异记录**：① 我猜步长只需改 `_incrementCounter` 一处，AI 方案额外在 body 加了"步长：$_step"显示和 AppBar 弹层——弹层方案符合指南"弹层选择步长 1/2/5"的原话，采纳；② 主题我只想到改 `seedColor`，AI 补充了 `useMaterial3` 与 `textTheme` 字体定制——正好覆盖作业"换主色与字体"的要求，采纳；③ 我原以为热重载能让新资源生效，AI 指出必须完整重启，实测证实 AI 正确。

## 八、证据截图

| 文件 | 说明 |
|---|---|
| docs/screenshots/02-counter-incremented.png | 应用整屏运行：teal 主题、AppBar 背景图、连点 FAB 后计数 2 |
| docs/screenshots/03-step-menu.png | AppBar 弹层展开，步长 1/2/5 可选 |
| docs/screenshots/04-step5-count7.png | 选步长 5 后点击 FAB，计数由 2 变 7（步长生效） |
| docs/screenshots/05-lifecycle-log.png | 控制台生命周期日志全文（含 r/R 对照段） |
| docs/screenshots/06-flutter-doctor.png | `flutter doctor -v` 输出（环境证据，可见 VS 缺失与 Chrome 可用） |
| docs/screenshots/07-git-log.png | Git 提交记录与远程仓库地址（5 次以上提交） |
| docs/widget-tree.png | Widget 树手绘图（完整层级＋两类 Widget 标注＋图例） |

## 九、自评

| 要求 | 完成情况 |
|---|---|
| 案例复现 counter_deep（代码一致、可运行、按步骤提交） | ✅ 三步骤各一次提交，另加初始化与证据提交共 6 次 |
| Widget 树手绘图（完整层级＋两类标注） | ✅ docs/widget-tree.png |
| 生命周期日志（钩子顺序＋r/R 对照） | ✅ 第五节对照表 |
| 主题定制（种子色方案＋至少两处 Theme.of） | ✅ teal＋inversePrimary／headlineMedium 两处取用，另定制字体 |
| 资源替换（新增图片并显示成功） | ✅ banner.png 作 AppBar 背景 |
| AI 使用标注（含对照差异记录） | ✅ 第七节 |
| Git 规范（3 次以上提交、仓库含 README） | ✅ 6 次提交，flutter create 自带 README |
| 独立研究任务（选做） | ⬜ 本次未做，列入下一步计划 |

## 十、一句话收获与下一步计划

**收获**：UI = f(state) 不是口号——这次把"改数据→setState→下一帧重建"在日志里逐行看到了，生命周期钩子在 r/R 下的行为差异也从抽象概念变成了可复现的实验。
**遗留问题**：① InheritedWidget 与 Theme 的底层关系还没亲手写过；② 本机缺 VS 工具链，Windows 桌面运行未验证。
**下次预习**：第 7 课导航与路由（routes、Navigator、BuildContext 向上查找的更多用法）；抽空完成独立研究任务 2（手写一个简单 InheritedWidget）。
