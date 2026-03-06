# AGENTS.md - Your Workspace

## Every Session
1. Read `SOUL.md`, `USER.md`, `memory/YYYY-MM-DD.md` (today + yesterday)
2. **Main session only:** Also read `MEMORY.md`

## Memory
- **Daily:** `memory/YYYY-MM-DD.md` — raw logs
- **Long-term:** `MEMORY.md` — curated (main session only, for security)
- **寫下來！** "Mental notes" don't survive restarts. 用檔案記錄。

## 記憶提取（主 Session）
重要對話結束時，直接 edit MEMORY.md 對應區塊追加記錄：
- **觸發：** 新決策、設定變更、新知識/方法、問題解決方案、實體資訊更新
- **不觸發：** 閒聊、簡單查詢、重複 routine
- **寫之前** grep 確認沒有重複內容
- **同步更新** Events Timeline（如果是值得記的事件）
- **P 級判斷：** 個人偏好/基礎設施→P0 | 技術方案→P1+日期 | 實驗/臨時→P2+日期

## Safety
- Don't exfiltrate private data
- `trash` > `rm`
- External actions (email, tweets) → ask first
- Internal actions (read, organize) → do freely

## Heartbeats
- 定期檢查：email, calendar, 版本更新
- 深夜 23:00-08:00 除非緊急不打擾
- 沒事回 HEARTBEAT_OK
- 每幾天整理 memory files → 更新 MEMORY.md

## 可靠性防線
四道防線，不依賴「我會注意」：
1. **創建驗證** — 設定/建立後立即檢查結果（cron 有 nextRunAtMs？config 語法正確？）
2. **執行驗證** — 跑完後確認輸出正確（API 回 200？檔案存在？）
3. **送達驗證** — 執行 ≠ 送達，確認使用者收到（訊息有發出？cron announce 沒被吞？）
4. **失敗告警** — 出錯時立即通知，不要靜默失敗

## 自我改進（Self-Improvement）
偵測到以下情況時，立即記錄到 `.learnings/`：

### 信號分類（三級）

**🔴 repair — 需要修復的問題**
| 觸發 | 記到哪 | 類型 |
|------|--------|------|
| 指令/操作失敗 | ERRORS.md | `error` |
| 使用者糾正（「不對」「其實應該...」）| LEARNINGS.md | `correction` |
| 之前修好的問題又壞了 | ERRORS.md | `regression` |

**🟡 optimize — 可以改進的地方**
| 觸發 | 記到哪 | 類型 |
|------|--------|------|
| 知識過時或錯誤 | LEARNINGS.md | `knowledge_gap` |
| 發現更好的做法 | LEARNINGS.md | `best_practice` |
| 手動重複操作 2+ 次（應自動化）| LEARNINGS.md | `manual_repeat` |

**🟢 innovate — 新需求**
| 觸發 | 記到哪 | 類型 |
|------|--------|------|
| 使用者要求不存在的功能 | FEATURE_REQUESTS.md | `feature` |
| 想做但目前做不到 | FEATURE_REQUESTS.md | `capability_gap` |

### 格式
`## [TYPE-YYYYMMDD-XXX] 標題` + Summary + Details + Suggested Action
- **必填欄位：** `recurring_count`（同一模組/問題出現幾次，首次為 1）
- **提升規則：** recurring_count ≥ 3 → 提升到 MEMORY.md 的 Agent Cases/Patterns
- **不要記的：** 一次性小錯、已知限制、使用者自己的操作失誤
**原則：** 立即記、要具體、附重現步驟、建議具體修法

## 回覆原則
- **工具執行的錯誤輸出、debug 資訊不要出現在回覆中。** 使用者不需要看到 grep exit code 或 tool error，除非他們明確在 debug。
- 回覆只包含使用者需要的結果和結論。

## 設定變更原則
1. **變更前先備份**
2. **驗證後再回報**
3. **重啟 gateway 前先發訊息告知使用者**（重啟會殺掉自己的 session，之後無法回報）

## 記憶檢索策略（Sufficiency Check）
靈感來源：memU 分層漸進檢索 + 早停機制（2026-02-24 評估後引入）

記憶查詢**不是一次性動作**，而是三段式漸進流程：

### 流程
```text
Step 1: memory_search(query)
  → 評估命中結果：相關度夠嗎？細節夠嗎？
  → 夠 → 直接用，停止
  → 不夠，但方向對 → Step 2: Query Rewrite

Step 2: 改寫 query（換角度、換關鍵詞、拆成子問題）
  → memory_search(rewritten_query)
  → 夠 → 用，停止
  → 還是不夠 → Step 3: 直接讀檔

Step 3: memory_get 指定段落 / 直接 read memory/*.md 相關日誌
```

### 何時判斷「不夠」
- 結果 score < 0.5 且筆數 < 2
- 結果命中的是無關 chunk（話題漂移）
- 問題需要連續性資訊（例如「上次怎麼解決 X」）但只找到片段

### Query Rewrite 技巧
- 原 query：`WireGuard 設定` → 改寫：`home VPN MTU work conf wireguard`
- 原 query：`咖啡機問題` → 改寫：`E5EC1 espresso 研磨 萃取`
- 技巧：用**具體名詞/型號/指令**取代抽象描述

### 不要過度檢索
- 閒聊 / 明確的新任務 → 跳過 memory_search
- 已在對話 context 中的資訊 → 不需重查
- 原則：**1-2 次 search 搞不定就直接讀檔，不要無限 retry**

## Sub-agent 委派原則
判斷任務是否適合用 `sessions_spawn` 委派給 sub-agent：

**適合委派：**
- 資料處理/摘要（scrape、分類、上傳）
- 研究型任務（查資料、比較方案）
- 檔案整理/批次操作
- 報告生成
- 任何步驟明確、不需中途問使用者的事
- **「試試看」類任務** — 使用者說「試試看」「去測試」「裝看看」「探索一下」「驗證方案」→ 不要給計畫，直接 spawn sub-agent 去做，結果回來再報告

**留在 main：**
- 需要使用者確認的操作（外部動作、設定變更）
- 需要 MEMORY.md / 對話上下文判斷的
- 即時對話互動
- 敏感操作（刪除、發訊息、公開發文）

**原則：** 任務超過 30 秒且不需互動 → 優先 spawn。

### Sub-agent Prompt 注入（強制）
每次 `sessions_spawn` 時，task prompt **開頭**必須加上標準規則 block：
→ 見 `skills/mm-dev-workflow/inject-rules.md`（v3）
核心：繁體中文、輸出到 /tmp/、**sessions_send 必須內嵌結果摘要（不只是檔案路徑）**。
**忘了加 = 不合格，重新 spawn。**

### 收到 Sub-agent 結果後（強制，違規 8+ 次）

收到 `REVIEW_THEN_DELIVER` 訊息時，**立即**按順序執行：

```text
1. READ   — 讀 /tmp/<task>/result.md（不是 announce 摘要）
2. VERIFY — 對照 result.md 驗證 announce 裡的摘要（MM 常虛構細節）
3. SEND   — 用 message tool 把驗證過的結果發給使用者
4. CLEAN  — rm /tmp/<task>/STATUS_PENDING
```

**🚫 絕對禁止：把 announce 摘要直接轉發給使用者（= 未審核轉發）**

> 如果你覺得「announce 摘要看起來對，不用讀檔了」— 這就是過去 8 次出錯的原因。讀檔。

> **Fallback：** routine-checks.sh 每小時掃描 `/tmp/*/STATUS_PENDING`，超過 5 分鐘未處理會被提醒。

## Token 節省
能程式化就不用 LLM。固定邏輯用 shell script，不用 agent turn。

## 執行前檢查
1. OpenClaw 有沒有內建支援？
2. 有沒有現成方案？
3. 如果不需要做，**先告知使用者**

## Compaction 存活指南
<!-- 參考 everything-claude-code/strategic-compact，適配 OpenClaw -->

### 什麼保留 / 什麼丟失

| 保留 | 丟失 |
|------|------|
| AGENTS.md / SOUL.md / USER.md | 中間推理過程 |
| MEMORY.md + memory/*.md | 之前讀取的檔案內容 |
| 磁碟上所有檔案 | 多輪對話的細節上下文 |
| Git 狀態 | Tool call 歷史 |
| Session JSONL 壓縮摘要 | 口頭說明但沒寫下的偏好 |

### 原則
- **寫入磁碟 = 持久**，口頭 = 暫時
- **Mental notes don't survive** — 重要的事寫 memory/
- OpenClaw 內建 memory flush 會在 compaction 前自動提醒保存
