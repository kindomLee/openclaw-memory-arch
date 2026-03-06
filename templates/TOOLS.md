# TOOLS.md - Quick Reference

> 在這裡記錄你常用的工具、連線方式、快速指令。Agent 每次醒來都會讀這份檔案。

## 常用連線

```bash
# 範例：主機 SSH
# ssh -p <port> <user>@<host>

# 範例：服務 API
# curl -H "Authorization: Bearer $TOKEN" https://<service>/api/
```

## 常用指令

```bash
# OpenClaw 版本
openclaw --version

# Cron 管理
openclaw cron list
openclaw cron add --name "名稱" --at "30m" --system-event "內容" --session main --wake now --delete-after-run
```

## 外部服務

| 服務 | URL | 用途 |
|------|-----|------|
| 範例 | `https://example.com` | 說明 |

## 注意事項

- 這份檔案是給 Agent 看的快查手冊，不是給人看的文件
- 敏感資訊（API key、密碼）不要直接寫在這裡，用環境變數或檔案路徑引用
