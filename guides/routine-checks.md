# Routine Checks Guide — 例行檢查指南

## 演進思路：從全 LLM 到固定邏輯

### 發展歷程
1. **初期**: 完全依賴 LLM 進行所有檢查和決策
2. **中期**: 發現重複性高的任務浪費 token 和時間
3. **現在**: 混合架構 — 固定邏輯處理常規任務，LLM 處理需要判斷的部分

### 為什麼要進化？
- **成本考量**: LLM token 成本高，重複性任務不值得
- **效率問題**: 固定邏輯執行速度快，結果穩定
- **可靠性**: 減少 LLM 的「創意發揮」，避免不必要的變化

## Type A vs Type B 檢查

### Type A: 監控型（Monitoring）
**特徵**: 有明確的正常/異常標準，可以用固定邏輯判斷

**範例**:
- 服務健康檢查（HTTP status code）
- 磁碟空間檢查（使用率超過閾值）
- 記憶檔案大小檢查（防止過大）
- API 配額檢查（剩餘量低於閾值）

**實作方式**: 純 shell script + 條件判斷

### Type B: 分析型（Analytical）
**特徵**: 需要內容理解和上下文判斷

**範例**:
- 新聞摘要和重要性評估
- 郵件內容分析和優先級分類
- 錯誤日誌模式分析
- 使用者意圖理解

**實作方式**: script 收集資料 → LLM 分析 → 基於結果採取行動

## 設計原則：能固定就固定

### 固定邏輯適用情況
- 數值比較（>、<、=）
- 狀態檢查（存在、不存在）
- 正則表達式匹配
- 文件/API 回應格式檢查

### LLM 介入時機
- 需要語義理解
- 需要上下文判斷
- 需要創意或變化
- 複雜的決策樹

## Crontab 模板範例

### 基礎結構
```bash
# OpenClaw Agent Routine Checks
# 編輯: crontab -e

# 每5分鐘：系統健康檢查
*/5 * * * * /path/to/workspace/scripts/health-check.sh

# 每小時：memory 檔案大小檢查
0 * * * * /path/to/workspace/scripts/memory-size-check.sh

# 每天 09:00：晨間報告
0 9 * * * /path/to/workspace/scripts/morning-report.sh

# 每天 22:00：daily-sync（需要 LLM）
0 22 * * * openclaw cron add --name "daily-sync" --at "now" --system-event "trigger daily sync" --session main

# 每週一 10:00：週報
0 10 * * 1 /path/to/workspace/scripts/weekly-summary.sh

# 每月1號：清理舊檔案
0 2 1 * * /path/to/workspace/scripts/cleanup-old-files.sh
```

### 混合模式範例
```bash
# health-check.sh - Type A 監控型
#!/bin/bash
set -e

WORKSPACE="/path/to/workspace"
ALERT_THRESHOLD=90

# 檢查磁碟空間
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$ALERT_THRESHOLD" ]; then
    openclaw cron add --name "disk-alert" --at "now" --system-event "⚠️ Disk usage: ${DISK_USAGE}%" --session main
fi

# 檢查 OpenClaw gateway 狀態
if ! pgrep -f "openclaw gateway" > /dev/null; then
    openclaw cron add --name "gateway-down" --at "now" --system-event "🔴 OpenClaw gateway is down" --session main
fi

# 檢查記憶檔案大小
MEMORY_DIR="$WORKSPACE/memory"
if [ -d "$MEMORY_DIR" ]; then
    LARGE_FILES=$(find "$MEMORY_DIR" -name "*.md" -size +1M)
    if [ -n "$LARGE_FILES" ]; then
        openclaw cron add --name "large-memory-files" --at "now" --system-event "📄 Large memory files found" --session main
    fi
fi
```

## 三層決策圖

```text
任務分類
    ├── 1. 純數值/狀態檢查
    │   └── → 固定腳本 + 閾值觸發
    │       
    ├── 2. 需要收集後判斷
    │   └── → 固定腳本收集 + LLM 決策
    │       
    └── 3. 複雜上下文理解
        └── → 完全交給 LLM
```

### 層級 1: 固定腳本
- **工具**: bash, python, curl
- **觸發**: 數值超過閾值
- **動作**: 直接發送 system event

### 層級 2: 混合模式
- **收集**: 固定腳本收集資料
- **決策**: LLM 分析內容
- **動作**: 基於 LLM 結果執行

### 層級 3: 純 LLM
- **場景**: 需要大量上下文
- **方式**: OpenClaw cron + sessions_spawn
- **優點**: 充分利用 Agent 能力

## System Crontab vs OpenClaw Cron

### System Crontab 適用場景
- **Type A 監控型檢查**
- 不需要 Agent 上下文
- 需要高可靠性（獨立於 OpenClaw）
- 系統級維護任務

**優點**:
- 獨立運行，不受 OpenClaw 狀態影響
- 執行效率高
- 適合週期性固定任務

**缺點**:
- 無法訪問 Agent 記憶和上下文
- 結果需要額外機制傳遞給 Agent

### OpenClaw Cron 適用場景
- **Type B 分析型檢查**
- 需要 Agent 記憶和上下文
- 需要複雜決策
- 需要與使用者互動

**優點**:
- 完整的 Agent 功能
- 可訪問記憶系統
- 支援複雜工作流程

**缺點**:
- 依賴 OpenClaw 運行狀態
- 相對耗費資源

## 語言選擇建議

### Bash
**適用**: 簡單的文件操作、API 調用、狀態檢查

**範例**:
```bash
# 檢查服務狀態
if systemctl is-active --quiet nginx; then
    echo "nginx: OK"
else
    echo "nginx: FAILED"
fi
```

### Python
**適用**: 複雜的數據處理、JSON 解析、多步驟邏輯

**範例**:
```python
import json
import requests

# API 配額檢查
response = requests.get('https://api.example.com/quota')
quota = response.json()

if quota['remaining'] < 100:
    print(f"⚠️ API quota low: {quota['remaining']} remaining")
```

### Rust
**適用**: 高效能需求、複雜邏輯、需要類型安全

**範例**:
```rust
// 高效率的日誌分析
use std::fs;
use regex::Regex;

fn analyze_logs() -> Result<Vec<String>, std::io::Error> {
    let content = fs::read_to_string("app.log")?;
    let error_pattern = Regex::new(r"ERROR.*").unwrap();
    
    Ok(error_pattern.find_iter(&content)
        .map(|m| m.as_str().to_string())
        .collect())
}
```

## 實作建議

### 1. 從簡單開始
先實作 Type A 監控型檢查，累積經驗後再加入 Type B

### 2. 漸進式遷移
將現有的全 LLM 檢查逐步拆分，固定邏輯部分先抽出來

### 3. 統一接口
所有腳本使用相同的輸出格式，方便後續處理

### 4. 錯誤處理
加入適當的錯誤處理和重試機制

### 5. 記錄和監控
記錄檢查結果，監控檢查本身的健康狀態

記住：**優化是個持續過程，先讓它運行起來，再逐步改進。**