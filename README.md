# AIM Desktop

[AIM](https://github.com/hellopoisonx/aim) 的桌面客户端, 使用 `Flutter` 开发。

## flutter

使用 `fvm` 进行版本管理

## UI

- 组件库: `Material3`
- 页面布局: `ui_examples/`

## 状态管理框架

[riverpod](https://riverpod.dev/)

## 网络请求

[dio](https://github.com/cfug/dio)

## 开发手册

- 客户端实现指南：`https://raw.githubusercontent.com/hellopoisonx/aim/refs/heads/main/docs/client_implement_instruction.md`
- REST OpenAPI：`https://raw.githubusercontent.com/hellopoisonx/aim/refs/heads/main/docs/api/gateway-openapi.yaml`
- WebSocket 协议：`https://raw.githubusercontent.com/hellopoisonx/aim/refs/heads/main/docs/ws.md`
- WS Proto：`https://raw.githubusercontent.com/hellopoisonx/aim/refs/heads/main/shared/proto/ws/ws.proto`

客户端实现以上述手册及其引用的 REST OpenAPI、WS 协议和 Proto 文件为准；应用内不再包含演示账号或内置 mock 数据。

## 本地缓存

[drift](https://pub.dev/packages/drift)

## 配置与运行

默认 Gateway 地址为 `http://127.0.0.1:8888`。可通过以下方式覆盖：

```bash
fvm flutter run --dart-define=AIM_GATEWAY_URL=https://gateway.example.com --dart-define=AIM_ENV_NAME=prod
```

也可以在本地 `.env` 中配置 `AIM_GATEWAY_URL` / `AIM_ENV_NAME`（不要提交真实密钥或个人配置）。

## 自动发布

项目包含 GitHub Actions 工作流 `.github/workflows/release.yml`，用于自动构建并发布桌面端安装包。

触发方式：

- 推送 `v*` tag，例如：`git tag v1.0.0 && git push origin v1.0.0`。
- 在 GitHub Actions 页面手动运行 `Release Desktop`，可选填写 `release_tag`；未填写时默认使用 `pubspec.yaml` 中的版本生成 `v版本号`。

发布产物：

- `aim_desktop-linux-x64.tar.gz`
- `aim_desktop-windows-x64.zip`
- `aim_desktop-macos.zip`
