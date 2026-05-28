# AIM Desktop 对照开发手册修复/更新计划

## Context

对照服务端 [开发手册](https://raw.githubusercontent.com/hellopoisonx/aim/refs/heads/main/docs/client_implement_instruction.md)
及其附属文件（`ws.md`、`ws.proto`、`gateway.proto`、`gateway-openapi.yaml`），
全面审查当前 Flutter 桌面客户端代码，逐一标记差距并形成分阶段实施计划。

### 现有代码优点（无需大改）

| 模块 | 现状 | 评价 |
|------|------|------|
| REST API 客户端 `gateway_api_client.dart` | 覆盖全部端点、统一响应格式、JSON 解析、错误码 | ✅ 基本完善 |
| WS 实时客户端 `gateway_realtime_client.dart` | 手动 Protobuf 编解码、seq/ACK/心跳/10 帧类型 | ✅ 功能完整 |
| 仓库层 `gateway_aim_repository.dart` | 桥接 REST+WS、实现 `AimRepository` 接口 | ✅ 架构合理 |
| 领域模型 `models.dart` | UserProfile、AuthSession、Conversation、ChatMessage、Friendship、AttachmentItem、AttachmentMessagePayload、AimState | ✅ 字段完整 |
| 控制器 `aim_controller.dart` | Riverpod 全状态管理、全部业务逻辑 | ✅ 流程覆盖 |
| UI | Material 3 暗色主题、响应式布局 | ✅ 可直接演进 |
| 附件模型 `AttachmentMessagePayload` | 支持 `aim.attachment.v1` schema、完整序列化 | ✅ |
| 群管理 REST 端点 | addMembers/removeMember/grantAdmin/revokeAdmin/transferOwner/dismissGroup 全部实现 | ✅ |

## Approach

按"数据持久化与协议安全 > 连接鲁棒性 > 消息正确性 > 高级特性 > 测试与环境"优先级分 6 阶段执行：

1. **基础设施**：Drift 本地缓存 + Protobuf 代码生成 + 环境配置
2. **认证与连接**：Token 持久化/自动刷新/安全存储 + WS 重连退避 + 断线恢复
3. **消息核心**：ACK 状态映射 + 重试策略 + 消息去重 + 回声匹配 + 历史翻页
4. **高级特性**：已读回执同步、在线状态恢复、输入状态、系统消息解析、通知
5. **测试与环境**：单元/组件/集成测试 + 多环境配置 + CI
6. **打磨**：性能优化、日志脱敏、错误处理完善

## Files to modify

### 依赖
- `pubspec.yaml` — 添加 `drift`、`drift_flutter`、`protobuf`、`path_provider`、`flutter_secure_storage`、`web_socket_channel`、`build_runner`、`drift_dev`

### 新建
- `lib/src/data/database.dart` — Drift 数据库定义（表：local_messages、local_read_states、conversations、sessions）
- `lib/src/data/database.g.dart` — Drift 代码生成
- `lib/src/data/secure_storage.dart` — Token 安全存储抽象
- `lib/src/data/gateway_config.dart` — 多环境配置
- `lib/src/data/ws_reconnect.dart` — WS 指数退避重连器
- `proto/ws.proto` — 本地副本（源：`shared/proto/ws/ws.proto`）
- `lib/src/data/generated/ws.pb.dart` — protobuf 代码生成

### 修改
- `lib/src/data/gateway_api_client.dart` — 添加 Dio 拦截器（自动注入 token、401 自动 refresh）
- `lib/src/data/gateway_realtime_client.dart` — 替换手动编解码为 protobuf 生成代码 + 重连逻辑 + Token 过期处理改进
- `lib/src/data/gateway_aim_repository.dart` — 接入 Drift 缓存层 + 历史翻页 + 离线恢复
- `lib/src/aim_controller.dart` — ACK 状态区分处理 + 消息重试退避 + 启动时 token 恢复 + 前台/后台生命周期
- `lib/src/domain/models.dart` — 添加 read_states 模型、系统消息事件模型
- `lib/src/aim_app.dart` — 启动时检查 refresh_token 自动恢复会话
- `lib/src/ui/workspace_page.dart` — 历史翻页 UI + 已读状态 UI
- `test/aim_controller_test.dart` — 扩展协议合规测试
- `test/widget_test.dart` — 扩展端到端测试
- `analysis_options.yaml` — 添加 lint 规则

## 详细差距分析

### 1. 基础设施层

#### 1.1 本地缓存（开发手册 §7）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| SQLite 本地消息缓存 | `local_messages` 表，`message_id` 主键 | 全部在内存 `AimState` |
| 已读状态表 | `local_read_states` 表 | 无持久化 |
| Drift 依赖 | README 提到 drift | `pubspec.yaml` 未包含 |
| WAL 模式 | "使用 WAL 模式 SQLite，禁止阻塞主线程" | 未实现 |

#### 1.2 Protobuf 编解码
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 代码生成 | "必须生成对应语言的序列化代码" | 手动 `_ProtoWriter`/`_ProtoReader` |
| 未知字段忽略 | proto3 未知字段应忽略 | 手动解析器跳过未知字段但不够健壮 |

#### 1.3 环境配置
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| Gateway 地址 | 多环境（本地/生产） | `const String.fromEnvironment('AIM_GATEWAY_URL')` 仅一处默认值 |

### 2. 认证与连接

#### 2.1 Token 管理（手册 §2.5）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 安全存储 | "存储 token 到设备安全区域（Keychain/Keystore/加密 SQLite）" | 仅内存 |
| 启动恢复 | "启动时若有有效 refresh_token，先尝试 refresh" | 无，始终跳转登录 |
| 定时刷新 | "过期前 60s 静默刷新" | 无定时器 |
| WS Token 过期 | 收到 `TOKEN_EXPIRED` → refresh → 新 token 重连 | 已实现基础流程，但缺少 `expired_at` 宽限期判断 |

#### 2.2 WS 重连（手册 §13.2）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 指数退避 | 0s, 1s, 2s, 4s, max 10s | 无自动重连，仅 `toggleConnection()` |
| 重连后恢复 | GET presence + 增量拉取 | 未实现 |
| 心跳超时 | 连续 60s 无消息 → 重连 | 有心跳发送但无超时检测 |

#### 2.3 Dio 拦截器
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 自动 Authorization | 每次请求携带 Bearer token | 手动 `setAccessToken()` |
| 401 自动 refresh | 收到 40100 → refresh token → 重试原请求 | 未实现 |

### 3. 消息核心

#### 3.1 ACK 状态映射（手册 §5.3）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 区分 ACCEPTED/REJECTED/RETRYABLE | 不同 status 有不同客户端行为 | 仅检查 `code != 0` 抛出异常 |
| 幂等命中 | "使用已有 message_id，不重复保存" | 未处理 |
| 限流退避 | "退避等待后重试" | 未处理 |

#### 3.2 消息重试（手册 §13.3）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| RETRYABLE 退避重试 | 1s, 2s, 4s，相同 client_msg_id，最多 5 次 | `retryMessage()` 只改状态回 sending，不重发 |
| 重试耗尽 | 标记 failed，显示"重发"按钮 | 无区分 |
| WS 断线保留 pending | "重连后自动补发" | 未实现 |

#### 3.3 消息去重（手册 §6.3）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| message_id 去重 | "message_id 为主键去重" | 去重仅按 `client_message_id` |
| 历史+在线交集去重 | "历史拉取结果 + 在线推送的交集用 message_id 去重" | 无持久化，无法判断 |

#### 3.4 client_msg_id 格式（手册 §5.4）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 格式 | `d1-UUID` | `client-{timestamp}-{random}` |
| 重试复用 | "重试时复用同一个值" | retryMessage 保留原值 ✅ |

#### 3.5 历史翻页（手册 §3.3）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 游标分页 | `cursor_created_at` + `cursor_id` | API client 解析了但仓库只做首次加载 |
| has_more 处理 | 判断是否到底 | 已解析 ✅，UI 未用 |
| 向上翻页 | 用上一页最后一条的 cursor | 未实现 |

### 4. 高级特性

#### 4.1 已读回执（手册 §9）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 服务端 read_states | 历史响应中的 `read_states` 填充 local_read_states | 未持久化 |
| PUSH_READ_RECEIPT | 已接收并处理 ✅ | 但未持久化 |
| 跨设备共享 | "以 user_id 为维度，跨设备共享" | 无数据层 |

#### 4.2 在线状态恢复（手册 §8.4）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 重连后 presence 快照 | `GET /api/presence/friends` | 已实现 bootstrap 快照，但重连后未刷新 |
| 增量同步 | "message_id > 本地最新的消息" | 未实现 |

#### 4.3 系统消息解析（手册 §12.2）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 事件类型解析 | member_joined/left/removed/renamed/avatar_changed/dismissed | 仅渲染 `isSystem` 文本，不解析 content JSON |
| 用户加入/退出通知格式 | `"user_id"` 等字段 | 未按事件类型差异化渲染 |

#### 4.4 通知（手册 §4.8）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| PushNotificationPayload | 系统通知展示 | 仅 SnackBar 提示，未做通知中心 |

### 5. 其他

#### 5.1 前端/后台生命周期（手册 §14.4）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 进入后台 | 暂停心跳 | 未实现 |
| 回到前台 | 检查 WS/重连/增量同步/刷新 presence | 未实现 |

#### 5.2 日志脱敏（手册 §15.2）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| Token/消息不打印 | "不在日志中打印 access_token, refresh_token, 或消息内容" | 未检查 |

#### 5.3 帧大小限制（手册 §15.4）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 1024 bytes | "当前服务端限制 1024 bytes" | 未限制发送帧大小 |

#### 5.4 Mentions 编码（手册 §15.3）
| 差距 | 手册要求 | 现状 |
|------|---------|------|
| 十进制字符串 | "mentions 使用十进制用户 ID 字符串" | 已正确实现 ✅ |

### 6. 模块覆盖清单（对照手册 §3.1 全部端点）

| REST 端点 | API Client | Repository | Controller | UI |
|----------|:---:|:---:|:---:|:---:|
| POST /api/auth/register | ✅ | ✅ | ✅ | ✅ |
| POST /api/auth/login | ✅ | ✅ | ✅ | ✅ |
| POST /api/auth/refresh | ✅ | ✅ | ✅ | ⬜ |
| POST /api/auth/logout | ✅ | ✅ | ✅ | ⬜ |
| GET /api/users/by-name/:name | ✅ | ✅ | ✅ | ✅ |
| GET /api/users/by-id/:id | ✅ | ✅ | - | - |
| POST /api/users/friends/:id | ✅ | ✅ | ✅ | ✅ |
| GET /api/friends/me | ✅ | ✅ | ✅ | ✅ |
| GET /api/friends/applications | ✅ | ✅ | ✅ | ✅ |
| POST /api/friends/accept/:id | ✅ | ✅ | ✅ | ✅ |
| POST /api/friends/reject/:id | ✅ | ✅ | ✅ | ✅ |
| POST /api/conversations | ✅ | ✅ | ✅ | ✅ |
| POST /api/conversations/group | ✅ | ✅ | ✅ | ✅ |
| GET /api/conversations | ✅ | ✅ | ✅ | ✅ |
| GET /api/conversations/history/:id | ✅ | ✅ | ✅ | ⬜ 翻页 |
| GET /api/conversations/:id/members | ✅ | ✅ | - | ⬜ |
| POST /api/conversations/:id/members | ✅ | ✅ | - | ⬜ |
| DELETE /api/conversations/:id/members/:uid | ✅ | ✅ | - | ⬜ |
| POST /api/conversations/:id/leave | ✅ | ✅ | ✅ | ⬜ |
| DELETE /api/conversations/:id | ✅ | ✅ | - | ⬜ |
| PUT /api/conversations/:id | ✅ | ✅ | ✅ | ⬜ |
| POST /api/conversations/:id/members/:uid/admin | ✅ | ✅ | - | ⬜ |
| DELETE /api/conversations/:id/members/:uid/admin | ✅ | ✅ | - | ⬜ |
| POST /api/conversations/:id/owner | ✅ | ✅ | - | ⬜ |
| GET /api/presence/friends | ✅ | ✅ | ✅ | ✅ |
| POST /api/attachments/init | ✅ | ✅ | ✅ | ✅ |
| POST /api/attachments/:id/complete | ✅ | ✅ | ✅ | ✅ |
| GET /api/attachments/:id | ✅ | ✅ | - | ⬜ |
| GET /api/attachments/:id/download | ✅ | ✅ | ✅ | ✅ |

### 7. WS 帧覆盖清单

| 帧类型 | 发送 | 接收 | ACK |
|-------|:---:|:---:|:---:|
| SEND_MESSAGE (1) | ✅ | - | ✅ |
| HEARTBEAT (2) | ✅ | - | ✅ |
| TYPING (3) | ✅ | - | - |
| READ_RECEIPT (4) | ✅ | - | ✅ |
| ACK (5) | ✅ | - | - |
| PUSH_MESSAGE (101) | - | ✅ | ✅ |
| PUSH_PRESENCE (102) | - | ✅ | ✅ |
| PUSH_NOTIFICATION (103) | - | ✅ | ✅ |
| PUSH_TYPING (104) | - | ✅ | ✅ |
| RECONNECT (105) | - | ✅ | ✅ |
| SERVER_ACK (106) | - | ✅ | - |
| TOKEN_EXPIRED (107) | - | ✅ | - |
| PUSH_FRIEND_APPLICATION (108) | - | ✅ | ✅ |
| PUSH_READ_RECEIPT (109) | - | ✅ | ✅ |

## Steps

### 阶段 1：基础设施

- [ ] **1.1** 添加依赖到 `pubspec.yaml`：`drift`、`drift_flutter`、`sqlite3_flutter_libs`、`path_provider`、`flutter_secure_storage`、`protobuf`、`build_runner`、`drift_dev`、`web_socket_channel`
- [ ] **1.2** 创建 `proto/ws.proto`（从 GitHub 源码同步）+ `build.yaml`，运行 `protoc` 生成 `lib/src/data/generated/ws.pb.dart`
- [ ] **1.3** 创建 Drift 数据库 `lib/src/data/database.dart`，按手册 §7 定义 `local_messages`、`local_read_states`、`local_conversations` 表 + DAO
- [ ] **1.4** 创建 `lib/src/data/secure_storage.dart` — `TokenStorage` 抽象（基于 `flutter_secure_storage`）
- [ ] **1.5** 添加 `flutter_dotenv` 依赖，创建 `.env` / `.env.staging` / `.env.prod` 文件。编译时通过 `--dart-define-from-file` 加载环境变量到 `String.fromEnvironment`。Gateway 地址等配置从 `.env` 读取，不写入 Git（`.env` 加入 `.gitignore`，提供 `.env.example` 模板）。默认 dev 地址 `http://127.0.0.1:8888`

### 阶段 2：认证与连接鲁棒性

- [ ] **2.1** 替换 `gateway_realtime_client.dart` 手动编解码为 `ws.pb.dart` 生成代码
- [ ] **2.2** 实现 Dio 拦截器：自动注入 `Authorization: Bearer` + 401 自动 refresh + 重试
- [ ] **2.3** 实现 Token 安全存储 + 启动时自动恢复（有 refresh_token → POST /api/auth/refresh → 进入主页）
- [ ] **2.4** 实现 access_token 定时刷新（过期前 60s）
- [ ] **2.5** 创建 `lib/src/data/ws_reconnect.dart`：指数退避重连器（0, 1s, 2s, 4s, max 10s）+ 心跳超时检测（60s 无消息→重连）
- [ ] **2.6** 重连后恢复流程：GET presence/friends + 活跃会话增量拉取

### 阶段 3：消息核心

- [ ] **3.1** 接入 Drift 缓存层：`gateway_aim_repository.dart` 读写本地数据库
- [ ] **3.2** ACK 状态区分处理：ACCEPTED→sent/rejected/failed/retryable，按手册 §5.3 表
- [ ] **3.3** 消息重试退避：RETRYABLE → 相同 client_msg_id 退避重试（1s, 2s, 4s），最多 5 次；失败→"重发"按钮
- [ ] **3.4** message_id 去重：收到 PUSH_MESSAGE 先查本地 DB；历史+在线交集去重
- [ ] **3.5** 修正 client_msg_id 格式：`d1-{UUID}`（手册 §5.4）
- [ ] **3.6** 历史翻页：实现 cursor 分页加载 + UI 上拉加载更多

### 阶段 4：已读回执 & 在线状态

- [ ] **4.1** 持久化 read_states 到 Drift，从历史响应同步
- [ ] **4.2** 会话未读计数基于服务端 read_states 计算
- [ ] **4.3** 重连后刷新 presence/friends
- [ ] **4.4** 系统消息事件解析（member_joined/left/removed 等差异化渲染）

### 阶段 5：高级特性

- [ ] **5.1** 前台/后台生命周期：AppLifecycleListener → 暂停/恢复心跳 + 重连
- [x] **5.2** 群成员管理 UI：添加/移除/授予管理/转让群主/解散群
- [ ] **5.3** 通知中心：PushNotificationPayload 展示列表
- [ ] **5.4** 帧大小检查：发送前检查 > 1024 bytes 给出警告

### 阶段 6：测试与环境

- [ ] **6.1** 扩展 `test/aim_controller_test.dart`：ACK 状态映射、重试逻辑、去重、token 刷新
- [ ] **6.2** 扩展 `test/widget_test.dart`：登录失败、token 过期恢复、消息发送失败重试
- [ ] **6.3** 新增 `test/gateway_api_client_test.dart`：REST 统一响应解析、错误码映射
- [ ] **6.4** 新增 `test/gateway_realtime_client_test.dart`：Protobuf 编解码正确性、seq 递增
- [ ] **6.5** 新增 `test/database_test.dart`：Drift 表结构 + DAO 操作
- [ ] **6.6** 多环境配置测试 + `analysis_options.yaml` lint 规则加强

## Reuse

| 现有文件 | 复用方式 |
|---------|---------|
| `lib/src/data/gateway_api_client.dart` | 保留全部 REST 端点实现，仅添加 Dio 拦截器 |
| `lib/src/data/gateway_realtime_client.dart` | 保留帧处理框架（事件流、seq、pending_acks），内部编解码替换为 protobuf 生成代码 |
| `lib/src/data/gateway_aim_repository.dart` | 保留仓库聚合逻辑，接入 Drift 缓存层 |
| `lib/src/domain/models.dart` | 保留全部领域模型，添加 ReadState、SystemEvent 等 |
| `lib/src/aim_controller.dart` | 保留全部业务流程，增强 ACK 状态处理 + 重试逻辑 + 生命周期 |
| `lib/src/ui/*` | 保留全部 UI 布局与组件，添加翻页等交互 |

## Verification

### 静态检查
```bash
fvm flutter analyze  # 或 flutter analyze
```

### 单元/组件测试
```bash
fvm flutter test
```
预期覆盖：协议映射、ACK 状态转换、消息去重、重试退避、token 刷新、数据库操作。

### 手动联调

> **本地开发**: 复制 `.env.example` → `.env`，配置 `AIM_GATEWAY_URL=http://127.0.0.1:8888`，运行 `fvm flutter run --dart-define-from-file=.env`。
> **切换环境**: 使用 `--dart-define-from-file=.env.staging` 或 `.env.prod`
1. 注册 → 登录 → 持久化 token → 重启应用自动恢复
2. 会话列表 + 历史消息翻页（向上加载更多）
3. WS 发送消息 → 确认 SERVER_ACK（ACCEPTED/REJECTED/RETRYABLE）
4. 收到 PUSH_MESSAGE → 去重 → 展示
5. 断网 → 指数退避重连 → 增量同步消息
6. Token 过期 → 自动 refresh → 重连
7. 已读回执发送与接收
8. 附件上传/下载
9. 群管理（创建、邀请、踢人、转让、解散）
10. 好友申请发送/接收/接受/拒绝

### 回归检查
- 离线恢复：重连后消息无遗漏、无重复
- 限流/无权限/Token 过期等错误路径提示
- 多设备消息同步验证
