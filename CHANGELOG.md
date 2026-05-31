# Changelog

## [Unreleased]

### 新增

- **搜索功能**：新增全局聚合搜索弹窗（侧边栏触发），支持跨用户、好友、会话、消息范围搜索（`_GlobalSearchDialog`）
- **会话内消息搜索**：聊天头部的搜索按钮现已可用，支持在指定会话中搜索消息（`_SearchDialog`），可选择"当前会话"或"全局搜索"范围
- **搜索结果展示**：新增 `_SectionLabel`、`_SearchResultTile`、`_RichSnippet` 等组件，支持 `<mark>` 标签高亮片段渲染
- **Token 刷新可靠性**：引入安全巡检定时器（每 30s 检查 token 是否即将过期），防止单次 Timer 被 OS 延迟导致连接过期
- **Token 刷新退避重试**：失败时指数退避重试最多 3 次（1s → 2s → 4s），超过上限后提示用户手动检查
- **AimState 搜索状态**：新增 `searchResults`（`UnifiedSearchResult?`）和 `isSearching`（`bool`）字段及其 `copyWith` 支持
- **桌面端自动发布**：新增 GitHub Actions 工作流 `.github/workflows/release.yml`，支持在推送 `v*` tag 或手动触发时自动构建 Linux / Windows / macOS 桌面产物并发布到 GitHub Release
- **Bot 管理中心**：新增用户侧 Bot 管理入口，支持创建、启用/停用、签发/轮换/撤销连接密钥、加入群聊和创建 Bot 直聊
- **群聊 @ 候选**：输入框支持基于会话成员详情生成 @ 候选，群内 Bot 可被 @ 提及

### 修复

- **TextEditingController 生命周期**：搜索弹窗的输入控制器改为由 `State` 持有并在 `State.dispose()` 中释放，避免弹窗退出动画期间重建 `TextField` 时使用已 dispose 的 controller
- **后台恢复连接**：`onAppResumed()` 现在正确重新评估 token 过期时间并重新启动定时器，而非仅恢复单次 Timer
- **后台暂停逻辑**：`onAppPaused()` 改用 `_stopTokenRefreshTimer()` 同步停止安全巡检定时器
- **群成员 Bot 名称显示**：打开群成员列表前按 OpenAPI 拉取 `GET /api/conversations/{id}/members`，使用成员详情中的 `name` 显示 Bot 名称
- **群聊 @ Bot 缺失**：进入群聊时自动刷新成员详情，避免 @ 候选仅依赖好友列表导致 Bot 不出现

### 重构

- **Token 刷新**：将 `refreshToken()` 拆分为 `_refreshTokenWithRetry()`（带退避重试）和 `_doRefreshToken()`（实际执行刷新），实时事件和生命周期回调统一走退避重试路径
- **搜索 API**：`AimController` 新增 `clearSearchResults()`、`performUnifiedSearch()`、`searchMessagesInConversation()` 方法，统一调用 `_activeRepository.search()`
