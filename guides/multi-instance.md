# Multi-instance Guide — 多實例部署指南

## 為什麼需要多 Instance？

單一 Agent 實例有其限制：

### 不同人格需求
- **工作 Agent**: 專業、效率導向
- **個人助理**: 輕鬆、生活化
- **專案 Agent**: 專注特定領域（如開發、研究）

### 不同用途分離
- **生產環境**: 穩定、保守的設定
- **實驗環境**: 測試新功能、新模型
- **監控 Agent**: 純粹的系統監控，不處理聊天

### 不同 Channel 需求
- **Telegram**: 即時回應，簡潔風格
- **Discord**: 社群互動，表情符號
- **Email**: 正式語調，完整資訊

## 架構設計

### 基本架構圖
```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Instance-1    │    │   Instance-2    │    │   Instance-3    │
│   (工作助理)    │    │   (個人助理)    │    │   (監控機器人)  │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ Workspace-1/    │    │ Workspace-2/    │    │ Workspace-3/    │
│ ├─ AGENTS.md    │    │ ├─ AGENTS.md    │    │ ├─ AGENTS.md    │
│ ├─ SOUL.md      │    │ ├─ SOUL.md      │    │ ├─ SOUL.md      │
│ ├─ memory/      │    │ ├─ memory/      │    │ ├─ memory/      │
│ └─ .learnings/  │    │ └─ .learnings/  │    │ └─ .learnings/  │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ Gateway:8080    │    │ Gateway:8081    │    │ Gateway:8082    │
│ State: /state1  │    │ State: /state2  │    │ State: /state3  │
│ Model: opus     │    │ Model: sonnet   │    │ Model: minimax  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    ┌─────────────────┐
                    │  Shared Resources │
                    │ ├─ scripts/      │
                    │ ├─ tools/        │
                    │ └─ reference/    │
                    └─────────────────┘
```

### 隔離 vs 共用決策

| 資源類型 | 隔離 | 共用 | 理由 |
|----------|------|------|------|
| **記憶系統** | ✅ | ❌ | 避免人格混淆 |
| **SOUL.md** | ✅ | ❌ | 不同人格定義 |
| **AGENTS.md** | ✅ | ❌ | 不同工作流程 |
| **工具腳本** | ❌ | ✅ | 減少維護成本 |
| **參考文檔** | ❌ | ✅ | 通用知識 |
| **Gateway Port** | ✅ | ❌ | 避免衝突 |
| **State 目錄** | ✅ | ❌ | 會話隔離 |
| **Cron 任務** | ✅ | ❌ | 避免重複執行 |

## Config 檔差異範例

### Instance 1: 工作助理 (work-agent.yaml)
```yaml
# OpenClaw Configuration - Work Assistant
host: "0.0.0.0"
port: 8080
workspace: "/home/user/workspaces/work-agent"
state_dir: "/home/user/workspaces/work-agent/.state"

models:
  default: "anthropic/claude-opus-4-6"
  
channels:
  - type: telegram
    token: "${TELEGRAM_WORK_BOT_TOKEN}"
    allowed_users: ["work_user_id"]
    
  - type: email
    smtp_host: "smtp.gmail.com"
    smtp_port: 587
    username: "${WORK_EMAIL}"
    password: "${WORK_EMAIL_PASSWORD}"

heartbeat:
  enabled: true
  interval_hours: 4
  active_hours: "09:00-18:00"
  timezone: "Asia/Taipei"

logging:
  level: "info"
  file: "/var/log/openclaw/work-agent.log"
```

### Instance 2: 個人助理 (personal-agent.yaml)
```yaml
# OpenClaw Configuration - Personal Assistant
host: "0.0.0.0"
port: 8081
workspace: "/home/user/workspaces/personal-agent"
state_dir: "/home/user/workspaces/personal-agent/.state"

models:
  default: "anthropic/claude-sonnet-4-20250514"
  
channels:
  - type: telegram
    token: "${TELEGRAM_PERSONAL_BOT_TOKEN}"
    allowed_users: ["personal_user_id"]
    
  - type: discord
    token: "${DISCORD_BOT_TOKEN}"
    guild_ids: ["personal_guild_id"]

heartbeat:
  enabled: true
  interval_hours: 2
  active_hours: "08:00-23:00"
  timezone: "Asia/Taipei"

logging:
  level: "debug"
  file: "/var/log/openclaw/personal-agent.log"
```

### Instance 3: 監控機器人 (monitor-agent.yaml)
```yaml
# OpenClaw Configuration - Monitor Bot
host: "127.0.0.1"
port: 8082
workspace: "/home/user/workspaces/monitor-agent"
state_dir: "/home/user/workspaces/monitor-agent/.state"

models:
  default: "mm"  # MiniMax for cost efficiency
  
channels:
  - type: telegram
    token: "${TELEGRAM_MONITOR_BOT_TOKEN}"
    allowed_users: ["admin_user_id"]

heartbeat:
  enabled: true
  interval_hours: 1
  active_hours: "00:00-23:59"  # 24/7
  timezone: "Asia/Taipei"

features:
  web_search: false  # 監控不需要網路搜索
  browser: false
  
logging:
  level: "warn"
  file: "/var/log/openclaw/monitor-agent.log"
```

## Systemd Service 模板

### 基本服務檔案
```ini
# /etc/systemd/system/openclaw-work.service
[Unit]
Description=OpenClaw Work Assistant
After=network.target
Requires=network.target

[Service]
Type=simple
User=openclaw
Group=openclaw
WorkingDirectory=/home/user/workspaces/work-agent
ExecStart=/usr/local/bin/openclaw gateway start --config /etc/openclaw/work-agent.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5
Environment=NODE_ENV=production

# 環境變數檔
EnvironmentFile=/etc/openclaw/work-agent.env

# 安全設定
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/home/user/workspaces/work-agent
ReadWritePaths=/var/log/openclaw

[Install]
WantedBy=multi-user.target
```

### 環境變數檔案
```bash
# /etc/openclaw/work-agent.env
TELEGRAM_WORK_BOT_TOKEN=1234567890:ABCDefghijklmnop
WORK_EMAIL=<your-email>
WORK_EMAIL_PASSWORD=<your-password>

# API Keys
OPENAI_API_KEY=<your-key>
ANTHROPIC_API_KEY=<your-key>

# 共用資源路徑
SHARED_SCRIPTS_PATH=/opt/openclaw/shared/scripts
SHARED_TOOLS_PATH=/opt/openclaw/shared/tools
```

### 服務管理腳本
```bash
#!/bin/bash
# manage-agents.sh

SERVICES=("openclaw-work" "openclaw-personal" "openclaw-monitor")

case "$1" in
    start)
        for service in "${SERVICES[@]}"; do
            echo "Starting $service..."
            sudo systemctl start "$service"
        done
        ;;
    stop)
        for service in "${SERVICES[@]}"; do
            echo "Stopping $service..."
            sudo systemctl stop "$service"
        done
        ;;
    restart)
        for service in "${SERVICES[@]}"; do
            echo "Restarting $service..."
            sudo systemctl restart "$service"
        done
        ;;
    status)
        for service in "${SERVICES[@]}"; do
            echo "=== $service ==="
            sudo systemctl status "$service" --no-pager -l
            echo
        done
        ;;
    logs)
        if [ -n "$2" ]; then
            sudo journalctl -f -u "openclaw-$2"
        else
            echo "Usage: $0 logs <work|personal|monitor>"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
```

## 注意事項

### 1. Port 衝突避免
確保每個實例使用不同的 port：
- Work Agent: 8080
- Personal Agent: 8081
- Monitor Agent: 8082

### 2. Cron 任務隔離
每個實例的 cron 任務要避免衝突：

**錯誤做法** - 所有實例都在同一時間執行：
```bash
# 三個實例都在 09:00 執行，會互相干擾
0 9 * * * /shared/scripts/daily-summary.sh
```

**正確做法** - 錯開時間執行：
```bash
# Work Agent: 09:00
# Personal Agent: 09:05  
# Monitor Agent: 09:10
```

### 3. State 目錄隔離
每個實例要有獨立的 state 目錄：
```yaml
# 錯誤：共用 state 目錄
state_dir: "/var/lib/openclaw/state"

# 正確：獨立 state 目錄
state_dir: "/var/lib/openclaw/work-agent/state"
```

### 4. 記憶系統隔離
避免不同實例的記憶互相污染：
```bash
# 工作 Agent 的記憶
/workspaces/work-agent/memory/2024-01-01.md

# 個人 Agent 的記憶（完全分離）
/workspaces/personal-agent/memory/2024-01-01.md
```

### 5. 共用資源管理
通用的腳本和工具可以共用：
```bash
# 共用腳本目錄
/opt/openclaw/shared/
├── scripts/
│   ├── backup.sh
│   ├── cleanup.sh
│   └── health-check.sh
└── tools/
    ├── weather.py
    └── calendar-parser.py
```

在各實例的 TOOLS.md 中引用：
```bash
# 共用天氣腳本
python3 /opt/openclaw/shared/tools/weather.py
```

### 6. 負載均衡
如果有大量請求，可以考慮：
- 用 nginx 做負載均衡
- 根據 channel 類型路由到不同實例
- 設定不同的 rate limit

## 部署檢查清單

- [ ] 每個實例有獨立的 workspace 目錄
- [ ] 每個實例有獨立的 config 檔案
- [ ] 每個實例使用不同的 port
- [ ] 每個實例有獨立的 state 目錄
- [ ] 環境變數正確設定且隔離
- [ ] Systemd service 檔案已建立
- [ ] Cron 任務時間已錯開
- [ ] 防火牆規則已設定
- [ ] 日誌輪替已設定
- [ ] 備份策略已實施

記住：**多實例不是為了複雜而複雜，而是為了更好地服務不同的需求。從簡單開始，逐步擴展。**