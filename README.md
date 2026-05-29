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
