# LEARNINGS.md - 學習改進

> 記錄知識缺口、最佳實踐發現、使用者糾正等改進機會

## 格式說明

每筆學習記錄使用以下格式：

```markdown
## [LEARNING-YYYYMMDD-XXX] 簡短標題

**Type:** [knowledge_gap/best_practice/correction/manual_repeat]

**Summary:** 一句話描述學到的東西

**Context:**
什麼情況下發現這個學習點

**What I Learned:**
具體學到的知識或方法

**Action Taken:**
基於這個學習採取的行動

**Impact:**
這個改進帶來的效果

**Fields:**
- recurring_count: [次數]
- module: [相關模組]
- priority: [low/medium/high]
- status: [noted/applied/integrated]
- learn_date: [學習日期]
```

## Type 說明

- **knowledge_gap**: 發現知識盲點或過時資訊
- **best_practice**: 發現更好的做法或流程
- **correction**: 使用者糾正了我的理解或行為
- **manual_repeat**: 發現重複手動操作，應該自動化

## 範例記錄

```markdown
## [LEARNING-20241201-001] GitHub API Rate Limit 處理

**Type:** knowledge_gap

**Summary:** 學會 GitHub API 的 rate limiting 機制和最佳實踐

**Context:**
執行批次 GitHub 操作時遇到 403 錯誤，原來不知道有 rate limit

**What I Learned:**
1. GitHub API 有每小時 5000 次請求限制（認證用戶）
2. 應該檢查 X-RateLimit-Remaining header
3. 可以用 conditional requests 減少 rate limit 消耗
4. 批次操作應該加入適當的延遲

**Action Taken:**
1. 更新 GitHub 相關腳本加入 rate limit 檢查
2. 在 TOOLS.md 中記錄 GitHub API 使用注意事項
3. 實作 rate limit aware 的 GitHub 操作函式

**Impact:**
避免了後續的 API 限制問題，提高了批次操作的可靠性

**Fields:**
- recurring_count: 1
- module: github
- priority: medium
- status: applied
- learn_date: 2024-12-01
```

```markdown
## [LEARNING-20241201-002] 使用者偏好：簡潔回覆

**Type:** correction

**Summary:** 使用者偏好簡潔直接的回覆，不要冗長的說明

**Context:**
回覆天氣查詢時提供了詳細的解釋，使用者說「太長了，簡單點就好」

**What I Learned:**
1. 日常查詢只要核心資訊
2. 技術解釋只有在被詢問時才提供
3. 可以用「需要詳細說明嗎？」來確認

**Action Taken:**
1. 更新 SOUL.md 加入簡潔回覆偏好
2. 調整常用查詢的回應模式

**Impact:**
提高了日常互動的效率和滿意度

**Fields:**
- recurring_count: 1
- module: interaction
- priority: high
- status: integrated
- learn_date: 2024-12-01
```

---

*記住：每個糾正都是改進的機會。記錄下來，避免重複同樣的錯誤。*