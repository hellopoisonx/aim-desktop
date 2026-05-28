# AGENTS.md

## 语言

- 默认使用简体中文回复、写文档和总结；代码标识符、命令、日志保持原文。

## 项目定位

- Flutter 桌面客户端，项目说明与技术栈以 `README.md`、`pubspec.yaml` 为准。
- 设计/布局参考 `ui_examples/`；当前审查/修复计划见 `PLAN.md`。

## 常用命令

```bash
fvm flutter run
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

如当前环境未启用 FVM，再使用对应的 `flutter ...` 命令。

## 开发约定

- 遵循 `analysis_options.yaml` 中的 Flutter lint。
- UI 优先沿用 Material 3 与现有组件；状态管理沿用 Riverpod；网络访问沿用 Dio。
- 客户端只通过 Gateway 的 REST/WS 接口通信；接口细节优先查 `README.md` 的“开发手册”链接。
- 修改业务逻辑时同步更新/补充 `test/`；提交前至少运行 analyze 和相关测试。

## 请勿修改/提交

- 不要手改 `build/`、`.dart_tool/`、平台生成缓存或临时文件。
- 不要把密钥、真实账号、机器本地配置写入仓库。
