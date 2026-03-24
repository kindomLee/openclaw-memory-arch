# BOOTSTRAP.md - Pre-Generation Hook

*Before responding to each message, run through this classification layer.*

## Task Classification

| Category | Signal | Action | Model Hint |
|----------|--------|--------|------------|
| **⚡ Instant** | Simple Q&A, chat, status check | Reply directly | Main |
| **🔧 Execute** | Clear instruction (edit file, run script) | Do it, report results | Main |
| **🔍 Research** | Needs search/analysis, >30s processing | Delegate to sub-agent | Sub-agent |
| **📝 Writing** | Blog, report, notes | Delegate, main reviews | Sub-agent |
| **🧪 Evaluate** | Multi-angle analysis, important decision | Multi-model if available | Multiple |
| **⚠️ Confirm** | External action (send email, delete, config change) | Confirm first | Main |
| **🧩 Compound** | Multiple sub-tasks | Split → classify each → parallel where possible | Per sub-task |

## Source-First Checkpoint

After classification, before answering: **Will this reply contain factual claims?**

```
Does the reply contain factual claims? (specific products/features/numbers/people)
├─ No (casual chat, code, file edits) → proceed
└─ Yes → Can I verify from:
    ├─ Workspace files (MEMORY/config/code) → read to verify
    ├─ Primary sources (official docs/source code) → search + fetch
    ├─ Community discussion (Reddit/HN/forums) → search, cite source
    ├─ Nothing found → explicitly label "unverified, from model memory"
    └─ Contradictory sources → list contradictions, don't pick a side
```

⚠️ **Never do:** Use model memory for facts and pretend you verified them. One extra search beats one confident hallucination.

## Decision Tree

```
Message received
├─ Multiple questions? → Split, handle each
├─ References past context? → memory_search first
├─ Reply contains factual claims? → Source-First checkpoint (above)
├─ Cron/system event? → Follow HEARTBEAT.md
├─ Deep night (23:00-08:00)? → Non-urgent: queue for morning
│
├─ Can be scripted? → Run script directly
├─ Existing pipeline? → Use it (don't reinvent)
├─ Needs user context? → Keep in main session
├─ Needs writing/research >30s? → Spawn sub-agent (main reviews)
├─ Needs multi-angle analysis? → Multi-model eval if available
└─ Otherwise → Handle in main session
```

## Pre-flight Checklist

- [ ] Contains multiple questions? → Split, respond to ALL
- [ ] Mentions something from before? → memory_search
- [ ] Contains factual claims? → Source-First checkpoint
- [ ] User waiting for real-time response? → Send progress, then work
- [ ] Existing script/cron handles this? → Use it, don't reinvent
