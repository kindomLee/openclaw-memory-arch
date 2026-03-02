
# OpenClaw Memory Architecture — 架構詳解

*本文件詳細說明三層記憶系統、P 級優先級、檢索策略、自動化維護與常見反模式。*

---

## 概述

OpenClaw 記憶系統是為 **24/7 運行的 proactive agent** 設計的多層次架構，核心原則：

1. **寫入磁碟 = 持久** — 口頭資訊是暫時的，寫入檔案才會留存
2. **分層漸進檢索** — 非一次性的搜尋，而是三段式流程
3. **分級維護** — 依重要性自動歸檔、標記或保留結論，而非一刀切刪除
4. **四道防線** — 創建→執行→送達→失敗告警

---

## 一、三層記憶儲存

### 1. Session 記憶（極短期）

每次 session 開始時自動讀取：

| 檔案 | 用途 |
|------|------|
| `SOUL.md` | Agent 角色定位 |
| `USER.md` | 使用者基本資料 |
| `memory/YYYY-MM-DD.md` | 當日對話日誌 |
| `MEMORY.md` | 長期記憶（main session 專用） |

### 2. Daily 記憶（中短期）

**路徑：** `memory/YYYY-MM-DD.md`

每次重要對話後自動記錄，格式包含：
- 時間戳
- 事件描述
- 技術細節或決策

**歸檔策略：**
- 90 天以上舊日誌 → 移至 `memory/archive/`
- Janitor cron 每日執行

### 3. Long-term 記憶（長期）

**路徑：** `MEMORY.md`

核心知識庫，分為以下區塊：

#### L0 結構（永久不動）

| 區塊 | 內容 |
|------|------|
| **Events Timeline** | 重要事件時間軸索引 |
| **User Profile** | 使用者基本資料 |
| **User Preferences** | 使用者偏好 |
| **User Entities** | 實體：寵物、設備、興趣 |
| **Infrastructure** | 基礎設施 |
| **Agent Cases & Patterns** | 可重用的問題解決方案 |

#### L1 結構（長期但可能過時）

| 區塊 | 保留規則 |
|------|----------|
| **Second Brain** | 永久 |
| **Tech Projects** | 90 天後標記待審 |
| **External Integrations** | 90 天後標記待審 |
| **Dev Workflows** | 90 天後標記待審 |

#### L2 結構（實驗/臨時）

| 區塊 | 保留規則 |
|------|----------|
| **Experiments** | 30 天後保留結論，刪除過程細節 |

---

## 二、P 級優先級系統

### P0 — 永久保留
個人偏好、基礎設施、Agent Cases、使用者資料、核心工作流程

### P1 — 長期保留但需審視
技術方案細節、工具串接。90 天後標記待審，由人類判斷保留或移除。

### P2 — 實驗/臨時
實驗性功能、測試記錄。30 天後保留結論（前 3 行摘要），刪除過程細節。

### 語法標記

```markdown
## Events Timeline [P0]
## Tech Project X [P1] [2026-03-02]
## Experiment Y [P2] [2026-03-01]
```

---

## 三、記憶檢索策略（Sufficiency Check）

靈感來源：memU 三層漸進檢索 + 早停機制

### 三段式流程

```
Step 1: memory_search(query)
  → 夠 → 停止
  → 不夠 → Step 2: Query Rewrite

Step 2: 改寫 query → memory_search(rewritten_query)
  → 夠 → 停止
  → 還是不夠 → Step 3: 直接讀檔

Step 3: 直接讀取 memory/*.md 相關日誌
```

> **注意：** 搜尋分數（score）依賴你的 agent 平台實作。OpenClaw 使用內建的 `memory_search`；其他平台可使用全文搜尋、BM25 或向量檢索，閾值需自行調整。

### 何時判斷「不夠」
- 結果相關度低且筆數少
- 命中無關 chunk（話題漂移）
- 需要連續性資訊但只找到片段

### Query Rewrite 技巧

| 原 Query | 改寫後 |
|----------|--------|
| `VPN 設定` | `home VPN MTU work conf wireguard` |
| `咖啡機問題` | `espresso 研磨 萃取 機器型號` |

**原則：** 用具體名詞/型號/指令取代抽象描述

### 不要過度檢索
- 閒聊 / 新任務 → 跳過搜尋
- 已在 context → 不需重查
- **1-2 次搞不定就直接讀檔**

---

## 四、自動化維護（Memory Janitor）

### 運作規則

| 類型 | 閾值 | 動作 |
|------|------|------|
| Events Timeline | >90 天舊月份 | 折疊成一行摘要 |
| P1 區塊 | >90 天 | 標記待審（需人類手動處理） |
| P2 區塊 | >30 天 | 保留結論（前 3 行），刪除過程細節 |
| memory/*.md 日誌 | >90 天 | 歸檔到 memory/archive/ |
| P0 / Cases / Patterns | 永久 | 不動 |

### 用法

```bash
python3 memory-janitor.py --dry-run   # 預覽
python3 memory-janitor.py --force     # 執行
python3 memory-janitor.py --notify    # 預覽 + 通知
```

---

## 五、四大可靠性防線

| 防線 | 說明 | 範例 |
|------|------|------|
| **創建驗證** | 設定後立即檢查結果 | cron 有 nextRunAtMs？ |
| **執行驗證** | 跑完後確認輸出正確 | API 回 200？檔案存在？ |
| **送達驗證** | 確認使用者收到 | 訊息有發出？ |
| **失敗告警** | 出錯時立即通知 | 不要靜默失敗 |

---

## 六、實戰範例：對話如何轉化為記憶

### 範例 1：新偏好（→ P0）

> 使用者：「以後回覆都用繁體中文，不要簡體。」

**記錄到 User Preferences [P0]：**
```markdown
- **溝通語言：** 繁體中文（不使用簡體）
```

### 範例 2：技術方案（→ P1）

> 使用者：「我用了 Caddy 做 reverse proxy，設定檔在 /etc/caddy/Caddyfile。」

**新開區塊：**
```markdown
## Caddy Reverse Proxy [P1] [2026-03-02]
- **設定檔：** /etc/caddy/Caddyfile
- **用途：** reverse proxy
```

### 範例 3：實驗記錄（→ P2）

> 使用者：「試試看用 18g 粉量萃取，看口感差異。」

```markdown
## 咖啡萃取實驗 [P2] [2026-03-02]
- **目標：** 比較 18g vs 20g 粉量口感差異
- **結果：** 待觀察
```

### 範例 4：不需要記的

> 「今天天氣不錯」「幫我查一下現在幾度」

→ 閒聊和一次性查詢不觸發記憶捕捉。

---

## 七、常見反模式 ⚠️

### 1. 把 MEMORY.md 當 Wiki 寫
**問題：** 什麼瑣碎細節都記，導致檔案膨脹、token 爆炸、檢索失準。
**解法：** 只記新決策、設定變更、偏好、問題解決方案。

### 2. 過度檢索（Infinite Retrieval Loop）
**問題：** 查不到就一直改寫 query 無限 retry。
**解法：** 最多 2 次 search，搞不定就直接讀檔。

### 3. 依賴口頭記憶（Mental Notes）
**問題：** 以為在對話中提到的事 agent 會永遠記得。
**解法：** 重要的事必須寫入檔案。

### 4. 記憶覆寫競態（Race Condition）
**問題：** 多個 sub-agent 或 cron 同時寫入同一檔案。
**解法：** MEMORY.md 只由 main session 寫入；sub-agent 寫臨時檔，由 main 整合。

---

## 八、第二大腦整合（選用）

```
memory/*.md → 定時 cron → notes/ ↔ Obsidian (sync)
```

- **PARA 結構：** 00-Inbox ~ 04-Archive
- **專案管理：** notes/01-Projects/

---

## 九、關鍵設計決策

| 決策 | 理由 |
|------|------|
| 不直接用 database | Markdown 人可讀，適合版本控制 |
| 分 P0/P1/P2 | 讓自動化維護有據可依 |
| 不用向量資料庫 | 漸進檢索足夠，減少部署複雜度 |
| heartbeat 優先記憶捕捉 | 避免對話結束後資訊丟失 |


