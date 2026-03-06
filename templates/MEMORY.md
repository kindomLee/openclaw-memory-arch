# MEMORY.md - Long-term Memory

*Last updated: YYYY-MM-DD*

## Events Timeline [P0]
<!-- 只保留本月。舊月份歸檔到 reference/timeline-archive.md -->

### YYYY-MM
- **MM-DD** 事件描述

## User Profile [P0]
- 語言 | 時區 | 主要聯繫方式

## User Preferences [P0]
- 回覆風格偏好
- 工具使用偏好
- Model 分工偏好

## User Entities [P0]
<!-- 使用者相關的人事物 -->

## Infrastructure [P0]
<!-- 基礎設施快查：主機、服務、連線方式 -->

### 快查
- **主機 A:** 用途 | IP/連線方式
- **主機 B:** 用途 | IP/連線方式

## Agent Cases & Patterns [P0]
<!-- 詳細 → reference/agent-cases.md -->
- **關鍵 patterns：**
  - 驗證四防線（創建/執行/送達/失敗告警）
  - sessions_send 回傳（統一機制）
  - 臨時檔用指定的 tmp 目錄
  - Sub-agent 報告必須驗證後再發
  - 「試試看」= 立刻 spawn
