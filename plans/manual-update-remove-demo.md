# 对照最新开发手册更新并移除演示/Mock 数据计划

## Context

- 用户要求：开发手册已更新，需要按最新手册同步客户端实现；同时**完全删除**演示账户与生产 mock 数据。
- 范围：完整覆盖 `README.md` 指向的客户端实现手册 `docs/client_implement_instruction.md` 的用户侧客户端能力（认证、REST、WS、ACK、本地缓存、漫游、已读、在线/输入状态、附件、群管理、错误重试、生命周期、性能与安全）。
- 已核对手册结构：最新手册包含 1~15 章；重点变更/要求包括：历史分页 cursor、`read_states`、protobuf WS、ACK 映射、`d1-UUID`、本地缓存 WAL、离线恢复增量同步、输入状态 2.5s 节流、WS 心跳超时/重连、后台/前台生命周期、1024 bytes WS 帧限制、日志/Token 安全。
- 当前项目已具备部分基础设施：`GatewayApiClient`、`GatewayRealtimeClient`、`GatewayAimRepository`、`AimLocalDatabase`、`SecureTokenStorage`、`WsReconnectManager`、`proto/ws.proto` 与 `lib/src/data/generated/ws.*.dart`。
- 当前仍存在必须删除的演示/Mock 入口：
  - `lib/src/aim_controller.dart`：默认注入 `DemoAimRepository`、存在 `demoLogin()`，并有 `simulateIncomingMessage()`、`simulateTyping()`、`toggleConnection()`、`sendAttachmentPreview()` 等产品内模拟行为；`_deviceId` 含 `demo`。
  - `lib/src/data/aim_repository.dart`：生产源码中包含 `DemoAimRepository`、演示用户、演示 token、模拟会话/好友/附件/服务单数据。
  - `lib/src/ui/auth_page.dart`：预填 `demo@aim.local` / `password123`，展示“使用演示账号进入”按钮和演示说明。
  - `lib/src/ui/workspace_page.dart`：有“模拟收到新消息”“模拟对方输入中”“模拟 Token 续期”“当前以演示状态模拟”等 UI 入口/文案。
  - `test/`：测试大量依赖 `DemoAimRepository` 与 `demoLogin()`，需要迁移为测试专用 fake。

## Approach

采用“先对齐规范基线，再移除 mock，再补齐完整能力”的单一路线：

1. **规范基线**： implementation 开始时重新拉取并核对 `client_implement_instruction.md`、`docs/ws.md`、`shared/proto/ws/ws.proto`、`shared/proto/gateway/gateway.proto`、`docs/api/gateway-openapi.yaml`，将本地 `proto/ws.proto` 与生成代码保持同步。
2. **生产代码零演示**：生产 `lib/` 中完全删除 `DemoAimRepository`、演示账号、演示 token、模拟按钮/动作/文案；测试需要的假数据只放在 `test/` 或 `test/support/`。
3. **完整手册能力补齐**：在现有 Gateway/Drift/SecureStorage/Protobuf 基础上补齐所有用户侧客户端要求，而不是保留“后续优化”缺口。
4. **安全与体验收口**：移除 token 明文展示/日志风险，修复设备 ID、WS 帧大小、输入节流、生命周期和重连恢复；UI 不再暴露手工模拟入口。

## Files to modify

关键文件：

- `README.md`：同步最新手册链接、环境变量、启动/验证说明；明确不再提供演示账号。
- `pubspec.yaml`：按完整能力补充/清理依赖；若做桌面通知，评估加入桌面通知插件；确认 `flutter_dotenv` 是否实际使用。
- `proto/ws.proto`、`lib/src/data/generated/ws.*.dart`：与最新 `shared/proto/ws/ws.proto` 保持一致，必要时重新生成。
- `lib/main.dart`：如继续使用 `.env`/多环境配置，在启动时加载配置；否则清理未使用依赖/说明。
- `lib/src/aim_app.dart`：确保生命周期回调真正触发 WS 心跳暂停/恢复、重连与增量同步。
- `lib/src/aim_controller.dart`：删除 `demoRepository` 与 `demoLogin()`；删除模拟方法；修复 `_deviceId`；补齐 ACK/重试、pending 补发、历史分页、已读持久化、重连恢复、通知中心、输入节流、后台/前台流程。
- `lib/src/data/aim_repository.dart`：删除 `DemoAimRepository`；只保留接口、DTO、通用附件辅助；必要时扩展接口承载完整手册能力（成员详情、通知、同步等）。
- `lib/src/data/gateway_api_client.dart`：对照最新 OpenAPI 更新 REST 字段、端点、错误码处理、401 refresh 重试、429/500 退避、附件下载授权、群管理、presence。
- `lib/src/data/gateway_aim_repository.dart`：实现完整生产仓库逻辑：本地缓存写入、read_states、历史 cursor、断线后 conversation/presence/active histories 增量同步、pending 补发、成员管理桥接。
- `lib/src/data/gateway_realtime_client.dart`：补齐 WS 心跳超时检测、关闭码处理、drain/token-expired 自动路径、帧大小保护、server seq ACK 追踪、pending ACK 清理。
- `lib/src/data/ws_reconnect.dart`：完善 90s 心跳超时、指数退避上限、取消/重置语义，并接入 repository/controller。
- `lib/src/data/database.dart` 与 `database.g.dart`：按手册校准表/索引/状态码；补齐缓存账户隔离、临时本地消息、read states、附件缓存、同步元数据与迁移策略。
- `lib/src/data/secure_storage.dart`：保留安全存储，必要时扩展设备 ID 持久化与安全清理。
- `lib/src/domain/models.dart`：补齐系统消息事件、通知模型、读状态/同步状态、消息状态（received/sending/sent/failed）等。
- `lib/src/ui/auth_page.dart`：清空默认输入，删除演示登录按钮和说明，登录/注册只走 Gateway。
- `lib/src/ui/workspace_page.dart`：删除所有模拟入口；增加真实历史翻页、群成员详情/添加/移除/管理员/转让/解散入口、通知/系统消息展示、真实连接状态。
- `test/`：迁移为 `test/support/fake_aim_repository.dart` 等测试专用 fake，更新 widget/controller/database/realtime 测试，确保生产源码不含 mock 数据。

## Reuse

- 复用 `AimRepository` 抽象，让 UI 仍只依赖领域接口。
- 复用 `GatewayApiClient` 覆盖 Gateway REST，避免新增重复 HTTP 层。
- 复用 `GatewayRealtimeClient` 的 protobuf WS 编解码与 `RealtimeEvent` 事件分发。
- 复用 `GatewayAimRepository` 聚合 REST + WS + Drift，本次补齐而非重写。
- 复用 `AimLocalDatabase` 的 Drift/WAL 基础，补表、补索引、补迁移。
- 复用 `SecureTokenStorage` 存取 token，扩展设备 ID 持久化。
- 复用 `SystemMessageEvent.displayText()`，按手册事件字段增强显示文案。
- 测试只复用 `AimRepository` 接口；fake/stub 放入 `test/`，不再污染生产 `lib/`。

## Steps

- [ ] **拉取并核对最新规范**：重新获取 `client_implement_instruction.md`、`ws.md`、`ws.proto`、`gateway.proto`、`gateway-openapi.yaml`；记录本地代码与规范差异。
- [ ] **同步 Proto/WS 基线**：更新 `proto/ws.proto`，重新生成 `ws.pb.dart`/`ws.pbenum.dart`/`ws.pbjson.dart`；确认帧类型、payload、ACK status、未知字段兼容测试通过。
- [ ] **删除生产演示代码**：移除 `DemoAimRepository`、`demoLogin()`、演示 token/用户/会话/服务单、模拟消息/输入/连接/附件入口、所有演示文案和 demo 默认值。
- [ ] **迁移测试 fake**：在 `test/support/` 新建 fake repository/fixtures，改造现有测试只引用测试目录 fake；新增断言确保 `lib/` 中不再出现演示账号和 `DemoAimRepository`。
- [ ] **认证与设备会话**：登录/注册/refresh/logout 全部按手册；设备 ID 使用持久随机 UUID；启动仅通过 refresh token 自动恢复；过期前 60s refresh；40100 自动 refresh 并重试原请求；登出清理本地 session。
- [ ] **REST 完整对齐**：核对用户、好友、会话、群、presence、附件端点字段；补齐 429/500 退避、400/403/404/409 不重试、错误提示映射；清理不真实的服务中心提交逻辑。
- [ ] **本地缓存完整化**：支持 message_id 主键去重、client_msg_id 索引、local_status=received/sending/sent/failed、created_locally、synced_at、read_states、附件与同步元数据；处理多账号缓存隔离和 Drift schema migration。
- [ ] **启动与云端漫游**：启动后按手册拉会话、每会话最近 50 条、presence 快照；支持向上翻页 cursor；下拉/重连时以本地最新 message_id 合并最新页，按 message_id 去重。
- [ ] **WS 连接与重连**：心跳 20~30s、超时 >90s 检测；断线/关闭码/token expired/drain 触发指数退避重连；重连成功后刷新 conversations、presence 并对活跃会话做增量同步。
- [ ] **消息发送与 ACK**：发送前写入本地 pending；`ACCEPTED` 保存服务端 `message_id`；幂等命中不重复保存；`RETRYABLE` 复用同一 `client_msg_id` 1s/2s/4s 最多 5 次；WS 断线保留 pending 并在重连后补发；重试耗尽后失败按钮重新生成 `client_msg_id`。
- [ ] **消息接收、去重与已读**：`PUSH_MESSAGE` 按 message_id/client_msg_id 去重并 ACK server seq；打开会话自动发送 READ_RECEIPT；`PUSH_READ_RECEIPT` 更新 UI 与 local_read_states；跨设备回声按 client_msg_id 处理。
- [ ] **在线/输入状态**：WS 连接/重连后先拉 `/api/presence/friends`；输入状态发送节流 ≥2.5s，UI 4s 清除；移除手工“模拟输入中”。
- [ ] **附件**：按手册执行 init → 上传授权 URL → complete → 发送 `aim.attachment.v1` 消息 → download 授权 URL；处理 URL 过期刷新、图片缓存与帧大小限制。
- [ ] **群聊与系统消息**：接入成员详情、添加/移除、管理员、群主转让、退出/解散、更新群资料；系统消息按 `member_joined/member_left/member_removed/group_renamed/group_avatar_changed/group_dismissed` 和字段差异渲染。
- [ ] **通知与生命周期**：实现 `PUSH_NOTIFICATION` 的应用内通知中心/提示；后台暂停心跳，前台检查 WS、恢复心跳/重连、增量同步、刷新 presence。
- [ ] **性能与安全**：限制 WS 发送帧 ≤1024 bytes，超长文本引导附件；日志/界面不显示完整 token 或消息敏感内容；生产建议 HTTPS/WSS；附件下载 URL 域名校验；历史页大小 50/最大 100。
- [ ] **UI 收口**：登录页无 demo；工作区无模拟按钮；连接状态只反映真实 WS；历史列表支持翻页/刷新；群管理、通知、设置仅展示真实能力。
- [ ] **测试补齐**：覆盖认证恢复、REST 错误重试、WS ACK/重连/token expired/drain、pending 补发、历史分页、消息去重、read receipt、typing throttle、附件、群管理、系统消息、mock 清理。

## Verification

- [ ] `fvm flutter pub get`（依赖或生成配置变更后）
- [ ] Proto 变更后运行项目约定的生成命令，并确认 `proto/ws.proto` 与 `lib/src/data/generated/ws.*.dart` 一致。
- [ ] `fvm flutter analyze`
- [ ] `fvm flutter test`
- [ ] 静态搜索确认生产源码无演示/mock 残留：`demo@aim.local`、`password123`、`DemoAimRepository`、`demoLogin`、`模拟`、`演示环境`。
- [ ] 手动端到端验证：
  - 登录页无预填账号、无演示登录。
  - 登录/注册/refresh/logout 只走 Gateway。
  - 启动恢复、WS 建连、心跳、token 过期重连、drain 重连符合手册。
  - 会话列表、历史首屏、向上翻页、下拉/重连增量同步按 message_id 去重。
  - 文本/附件消息 ACK、RETRYABLE、REJECTED、断线 pending 补发行为正确。
  - 已读回执、presence、typing、系统消息、通知、群管理入口均使用真实接口/推送。
  - 日志和 UI 不暴露完整 token、refresh token 或本地敏感配置。

## Decisions

- 生产代码中**完全删除**演示仓库和演示账号；测试 fake 仅允许位于 `test/`。
- 本次按手册做完整覆盖，不把通知、生命周期、群管理 UI 等高级能力降级为后续优化。
