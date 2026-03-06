# ERRORS.md - 錯誤追蹤

> 記錄需要修復的問題，包含指令失敗、使用者糾正、功能回歸等

## 格式說明

每筆錯誤記錄使用以下格式：

```markdown
## [ERROR-YYYYMMDD-XXX] 簡短標題

**Summary:** 一句話描述錯誤

**Details:**
- 觸發條件：什麼情況下發生
- 錯誤現象：實際看到的錯誤
- 預期結果：應該要怎樣
- 重現步驟：如何重現這個錯誤

**Root Cause:**
根本原因分析

**Fix Applied:**
實際的修復方法

**Prevention:**
如何預防同類錯誤

**Fields:**
- recurring_count: [次數]
- module: [相關模組]
- severity: [low/medium/high]
- status: [pending/investigating/resolved]
- fix_date: [修復日期]
```

## 範例記錄

```markdown
## [ERROR-20241201-001] OpenClaw Gateway 啟動失敗

**Summary:** Gateway 無法綁定到指定端口

**Details:**
- 觸發條件：執行 `openclaw gateway start`
- 錯誤現象：Error: listen EADDRINUSE :::8080
- 預期結果：Gateway 正常啟動在 8080 端口
- 重現步驟：先啟動一個實例，再啟動第二個實例

**Root Cause:**
端口 8080 已被另一個 OpenClaw 實例占用，但沒有適當的端口衝突檢查

**Fix Applied:**
1. 檢查端口使用狀況：`lsof -i :8080`
2. 修改配置使用不同端口：8081
3. 加入啟動前端口檢查邏輯

**Prevention:**
在 AGENTS.md 中加入多實例部署注意事項，確保每個實例使用不同端口

**Fields:**
- recurring_count: 1
- module: gateway
- severity: medium
- status: resolved
- fix_date: 2024-12-01
```

---

*記住：越早記錄，越容易修復。不要等問題重複出現才開始追蹤。*