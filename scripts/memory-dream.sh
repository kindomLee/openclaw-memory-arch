#!/bin/bash
# memory-dream.sh — Cold memory association ("dreaming")
# Randomly pairs unrelated memories for cross-domain insights
# Inspired by Karry's Orb AI assistant (2026-03)
set -euo pipefail

WORKSPACE="${OPENCLAW_WORKSPACE:-$(cd "$(dirname "$0")/.." && pwd)}"
MEMORY_DIR="$WORKSPACE/memory"
MEMORY_MD="$WORKSPACE/MEMORY.md"
OUTPUT="$MEMORY_DIR/dreams.md"
NOTIFY=${1:-true}

# Collect recent memory snippets (last 30 days, skip archives)
SNIPPETS=$(find "$MEMORY_DIR" -maxdepth 1 -name "2*.md" -mtime -30 \
  ! -name "dreams.md" ! -name "reflections.md" ! -name "soul-proposals.md" \
  ! -name "compaction-buffer.md" 2>/dev/null | sort -R | head -8)

if [ -z "$SNIPPETS" ]; then
  echo "No memory files found to dream about"
  exit 0
fi

# Also grab some MEMORY.md sections randomly
MEMORY_SECTIONS=""
if [ -f "$MEMORY_MD" ]; then
  MEMORY_SECTIONS=$(grep -n "^## \|^### \|^- \*\*" "$MEMORY_MD" | shuf | head -5 | cut -d: -f2-)
fi

# Build the prompt
PROMPT="You are a 'dreaming' engine. Below are memory fragments from different times and domains.
Your task: find **unexpected connections** between these seemingly unrelated memories.

Rules:
- Don't just summarize — find **non-obvious links**
- Each insight in 1-2 sentences
- Only output valuable ones (if none, say 'No meaningful associations this time')
- Max 3 insights

=== Memory Fragments ===
"

for f in $SNIPPETS; do
  basename=$(basename "$f")
  content=$(head -20 "$f" 2>/dev/null || true)
  PROMPT="$PROMPT
--- $basename ---
$content
"
done

if [ -n "$MEMORY_SECTIONS" ]; then
  PROMPT="$PROMPT
--- MEMORY.md excerpts ---
$MEMORY_SECTIONS
"
fi

DATE=$(date +%Y-%m-%d)

# Use OpenClaw isolated session (model-agnostic)
RESULT=$(openclaw cron run-now \
  --message "$PROMPT" \
  --session isolated \
  --timeout 60 2>/dev/null || true)

# Fallback: if openclaw cron run-now not available, try openclaw message
if [ -z "$RESULT" ]; then
  # Write prompt to temp file for openclaw to process
  PROMPT_FILE=$(mktemp)
  echo "$PROMPT" > "$PROMPT_FILE"
  
  # Trigger via cron add with immediate execution
  openclaw cron add \
    --name "dream-${DATE}" \
    --at "5s" \
    --session isolated \
    --message "$PROMPT" \
    --announce \
    --delete-after-run 2>/dev/null
  
  rm -f "$PROMPT_FILE"
  echo "Dream triggered via OpenClaw cron (results will be announced)"
  exit 0
fi

# Append to dreams.md
{
  echo ""
  echo "### $DATE"
  echo "$RESULT"
} >> "$OUTPUT"

echo "✅ Dream recorded to $OUTPUT"

# Notify if requested
if [ "$NOTIFY" = "true" ]; then
  openclaw message send "🌙 Cold Memory Association (Dream)

$RESULT

_Source: memory-dream.sh_" 2>/dev/null || true
fi
