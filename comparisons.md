
# 記憶方案比較分析

*本文件比較 OpenClaw Memory Architecture 與其他主流 agent 記憶方案。*

---

## 方案比較矩陣

| 方案 | 類型 | 儲存格式 | 檢索方式 | 優先級 | 適用場景 |
|------|------|----------|----------|--------|----------|
| **OpenClaw** | 混合型 | Markdown | 三層漸進 | P0/P1/P2 | 24/7 proactive agent |
| **memU** | 框架 | SQLite + Markdown | 向量檢索 | 有 | 長期運行 agent |
| **Claude Code** | 原生 | Markdown | 全文 + 自動 | 無 | Coding assistant |
| **mem0** | 服務 | 雲端 DB | 向量檢索 | 無 | 通用 AI |
| **Letta** | 平台 | 雲端 | 結構化 + RAG | 有 | Stateful agents |
| **LangMem** | 庫 | 可選 | RAG | 無 | LangChain 應用 |
| **A-MEM** | 框架 | 可選 | Agentic 組織 | 無 | 動態記憶組織 |
| **SimpleMem** | 庫 | 可選 | 語義壓縮 | 無 | 大規模長期記憶 |

---

## 詳細分析

### 1. memU（NevaMind）

**GitHub:** https://github.com/NevaMind-AI/memU

為 24/7 proactive agents 設計的記憶框架。SQLite + Markdown 混合儲存，支援跨任務 skill 記憶與重用。OpenClaw 的 Sufficiency Check 檢索 pattern 受其啟發。

| 面向 | memU | OpenClaw |
|------|------|----------|
| 儲存 | SQLite + Markdown | 純 Markdown |
| 檢索 | 向量檢索 | 三層漸進 |
| 壓縮 | 智能壓縮 | 閾值規則 |

### 2. Claude Code 原生記憶

**文檔：** https://code.claude.com/docs/en/memory

三層架構（Project / User / Auto Memory）。最佳實踐：< 200 行 rule application rate > 92%。OpenClaw 分離行為（AGENTS.md）與知識（MEMORY.md），職責更清晰。

### 3. mem0

**GitHub:** https://github.com/mem0ai/mem0

通用 AI 記憶層，向量儲存。需雲端或自架服務，OpenClaw 偏好本地 Markdown。

### 4. Letta

**網站：** https://www.letta.com

Stateful agents 平台，需要託管。OpenClaw 完全本地部署。

### 5. LangMem

**文檔：** https://langchain-ai.github.io/langmem/

專注 LangChain 生態。OpenClaw 有自己的 memory skill。

### 6. A-MEM

**GitHub:** https://github.com/agiresearch/A-mem

Agent 自主組織記憶。OpenClaw 偏向人類驅動 + janitor 自動維護。

### 7. SimpleMem

**GitHub:** https://github.com/aiming-lab/SimpleMem

語義無損壓縮。技術導向 vs OpenClaw 實用導向。

### 8. GitHub Copilot Agentic Memory

**部落格：** https://github.blog/ai-and-ml/github-copilot/building-an-agentic-memory-system-for-github-copilot/

引用驗證機制。OpenClaw 目前無此功能（未來可考慮）。

---

## OpenClaw 方案的優勢

| 優勢 | 說明 |
|------|------|
| **本地部署** | 不依賴雲端服務 |
| **人類可讀可控** | Markdown，隨時檢視或修改 |
| **無廠商鎖定** | 純檔案系統 |
| **分優先級** | P0/P1/P2 自動化維護 |
| **第二大腦整合** | Obsidian 雙向同步 |

---

## 可改進方向

| 方向 | 來源靈感 | 優先度 |
|------|----------|--------|
| Skill 跨任務重用 | memU | 高 |
| Auto Memory | Claude Code | 中 |
| 引用驗證 | GitHub Copilot | 低 |
| 向量檢索增強 | memU | 低 |


