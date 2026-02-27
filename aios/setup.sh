#!/bin/bash
# AI OS Setup — One-command initialization
# Run: chmod +x setup.sh && ./setup.sh

set -e

echo ""
echo "=============================="
echo "  AI OS — Setup"
echo "=============================="
echo ""

# 1. Check prerequisites
if ! command -v claude &> /dev/null; then
    echo "[!] Claude Code CLI not found."
    echo "    Install it first: https://docs.anthropic.com/en/docs/claude-code"
    echo "    Then re-run this script."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "[!] Python 3 not found. Some skills need Python for scripts."
    echo "    Install: brew install python3 (macOS) or apt install python3 (Linux)"
    echo "    Continuing anyway — core skills work without Python."
    echo ""
fi

# 2. Create directories (safe — won't overwrite existing)
echo "[1/6] Creating directories..."
mkdir -p memory/logs
mkdir -p data
mkdir -p data/capture_markers
mkdir -p logs
mkdir -p .tmp

# 3. Create .env from example (if not exists)
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "[2/6] Created .env from template — edit with your API keys (optional)"
    else
        echo "[2/6] No .env.example found — skipping"
    fi
else
    echo "[2/6] .env already exists — skipping"
fi

# 4. Create settings.local.json from example (if not exists)
if [ ! -f .claude/settings.local.json ]; then
    if [ -f .claude/settings.local.json.example ]; then
        cp .claude/settings.local.json.example .claude/settings.local.json
        echo "[3/6] Created .claude/settings.local.json from template"
    else
        echo "[3/6] No settings template found — skipping"
    fi
else
    echo "[3/6] .claude/settings.local.json already exists — skipping"
fi

# 5. Create today's daily log (if not exists)
TODAY=$(date +%Y-%m-%d)
TODAY_LOG="memory/logs/${TODAY}.md"
if [ ! -f "$TODAY_LOG" ]; then
    cat > "$TODAY_LOG" << EOF
# Daily Log: ${TODAY}

> Session log for $(date +'%A, %B %d, %Y')

---

## Events & Notes

EOF
    echo "[4/6] Created today's log: ${TODAY_LOG}"
else
    echo "[4/6] Today's log already exists — skipping"
fi

# 6. Check for optional memory upgrade
echo "[5/6] Checking optional upgrades..."
if [ -f setup_memory.py ]; then
    echo "      Advanced memory system available (mem0 + Pinecone)"
    echo "      Run: python3 setup_memory.py --help"
    echo "      Or the business-setup wizard will offer to set it up."
else
    echo "      No optional upgrades found."
fi

# 7. Print next steps
echo "[6/6] Setup complete!"
echo ""
echo "=============================="
echo "  Next Steps"
echo "=============================="
echo ""
echo "  1. (Optional) Edit .env with your API keys"
echo "     Core skills work without any API keys."
echo ""
echo "  2. Launch Claude Code:"
echo "     claude"
echo ""
echo "  3. Say: \"Set up my business\""
echo "     The setup wizard will configure the system"
echo "     for YOUR specific business."
echo ""
echo "=============================="
echo ""
