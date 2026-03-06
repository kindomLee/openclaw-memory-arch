# HEARTBEAT.md

## 架構

```text
system crontab (定時執行)
  → routine-checks（固定邏輯腳本）
    → Type A：有異常直接通知
    → Type B：收集資料 → spawn LLM 分析

openclaw cron（需 LLM 的任務）
  → isolated session
  → 結果 announce 或 sessions_send
```

## 檢查項目範例

| 檢查 | 類型 | 間隔 | 說明 |
|------|------|------|------|
| 服務健康 | Type A | 5 min | HTTP ping，異常通知 |
| 磁碟空間 | Type A | 1 hr | 超過閾值通知 |
| 郵件分析 | Type B | 1 hr | 收集未讀郵件 → LLM 判斷重要性 |
| 記憶整理 | Type B | 1 day | 過期記憶歸檔 |

## 設計原則

- **能腳本化就不用 LLM**
- **先收集再判斷**：腳本收集資料，LLM 只做需要理解力的事
- **監控系統自己不能是不穩定因素**

詳細指南：見 `guides/routine-checks.md`
