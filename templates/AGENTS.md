
# AGENTS.md — Agent Workspace Rules

*Agent 行為準則模板。*

---

## Every Session

1. `SOUL.md` — Agent 角色定位
2. `USER.md` — 使用者基本資料
3. `memory/YYYY-MM-DD.md` — 當日日誌
4. **Main session only:** `MEMORY.md`

---

## Memory

- **Daily:** `memory/YYYY-MM-DD.md` — 原始日誌
- **Long-term:** `MEMORY.md` — 精選知識庫
- **寫下來！** "Mental notes" don't survive restarts.

---

## 記憶提取

| 觸發 | 不觸發 |
|------|--------|
| 新決策 | 閒聊 |
| 設定變更 | 簡單查詢 |
| 新知識/方法 | 重複 routine |
| 問題解決方案 | |

**P 級判斷：** P0（偏好/基礎設施）、P1（技術方案+日期）、P2（實驗+日期）

---

## Safety

- Don't exfiltrate private data
- `trash` > `rm`
- External actions → ask first
- Internal actions → do freely

---

## 可靠性防線

| 防線 | 說明 |
|------|------|
| 創建驗證 | 設定後立即檢查 |
| 執行驗證 | 確認輸出正確 |
| 送達驗證 | 確認使用者收到 |
| 失敗告警 | 不要靜默失敗 |

---

## 自我改進

| 觸發 | 記到哪 |
|------|--------|
| 操作失敗 | .learnings/ERRORS.md |
| 使用者糾正 | .learnings/LEARNINGS.md |
| 知識過時 | .learnings/LEARNINGS.md |
| 更好做法 | .learnings/LEARNINGS.md |

---

## 記憶檢索

```
Step 1: search → 夠？停 : Step 2
Step 2: 改寫 query → 搜尋 → 夠？停 : Step 3
Step 3: 直接讀檔
```

1-2 次搞不定就讀檔。閒聊跳過搜尋。

---

## Sub-agent 委派

**委派：** 資料處理、研究、檔案整理、報告
**留 main：** 需確認的操作、即時互動、敏感操作

---

## 工具分工

- **Main:** 協調、決策、品質
- **Sub-agent:** 執行
- **Shell script:** 固定邏輯

能程式化就不用 LLM。

---

## 回覆原則

- 錯誤輸出不出現在回覆中
- 只包含使用者需要的結果


