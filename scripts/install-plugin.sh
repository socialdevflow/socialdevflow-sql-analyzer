#!/bin/bash
# ============================================================
# Socialdevflow SQL Analyzer — Local Install Script
# Usage: bash scripts/install-plugin.sh
# Tested: macOS, Linux (Cursor 2.5+)
# ============================================================

set -e

PLUGIN_NAME="socialdevflow-sql-analyzer"
GITHUB_REPO="https://github.com/socialdevflow/socialdevflow-sql-analyzer.git"
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"   # root of plugin folder

# ── Destination paths (Cursor discovers local plugins under plugins/local/) ──
CURSOR_PLUGINS_DIR="$HOME/.cursor/plugins/local/$PLUGIN_NAME"
LEGACY_PLUGINS_DIR="$HOME/.cursor/plugins/$PLUGIN_NAME"
LEGACY_ORACLE_DIR="$HOME/.cursor/plugins/oracle-sql-optimizer"
CLAUDE_PLUGINS_JSON="$HOME/.claude/plugins/installed_plugins.json"
CLAUDE_SETTINGS_JSON="$HOME/.claude/settings.json"

echo ""
echo "🔧  Socialdevflow SQL Analyzer — Install"
echo "   GitHub repo   : $GITHUB_REPO"
echo "   Plugin source : $PLUGIN_DIR"
echo "   Install target: $CURSOR_PLUGINS_DIR"
echo ""

# ── Step 1: Copy plugin files ────────────────────────────────
echo "📁  Copying plugin files..."
rm -rf "$CURSOR_PLUGINS_DIR" "$LEGACY_PLUGINS_DIR" "$LEGACY_ORACLE_DIR"
mkdir -p "$CURSOR_PLUGINS_DIR"

for component in .cursor-plugin commands rules skills scripts logo.png logo_512.png README.md CHANGELOG.md LICENSE; do
  src="$PLUGIN_DIR/$component"
  if [ -e "$src" ]; then
    cp -R "$src" "$CURSOR_PLUGINS_DIR/"
    echo "    ✓ $component"
  fi
done

# ── Step 2: Register in installed_plugins.json ───────────────
echo ""
echo "📝  Registering plugin..."
mkdir -p "$(dirname "$CLAUDE_PLUGINS_JSON")"

PLUGIN_ENTRY=$(cat <<JSON
{
  "plugins": {
    "${PLUGIN_NAME}@local": [
      {
        "scope": "user",
        "installPath": "$CURSOR_PLUGINS_DIR"
      }
    ]
  }
}
JSON
)

if [ -f "$CLAUDE_PLUGINS_JSON" ]; then
  # Merge: add our entry without overwriting others
  # Requires python3 (available on most systems)
  python3 - "$CLAUDE_PLUGINS_JSON" "$PLUGIN_NAME" "$CURSOR_PLUGINS_DIR" <<'PYEOF'
import json, sys

json_file = sys.argv[1]
plugin_name = sys.argv[2]
install_path = sys.argv[3]
key = f"{plugin_name}@local"
stale_keys = ("oracle-sql-optimizer@local",)

with open(json_file, "r") as f:
    data = json.load(f)

plugins = data.setdefault("plugins", {})
for stale in stale_keys:
    plugins.pop(stale, None)
plugins[key] = [{"scope": "user", "installPath": install_path}]

with open(json_file, "w") as f:
    json.dump(data, f, indent=2)
print(f"    ✓ Merged into {json_file}")
PYEOF
else
  echo "$PLUGIN_ENTRY" > "$CLAUDE_PLUGINS_JSON"
  echo "    ✓ Created $CLAUDE_PLUGINS_JSON"
fi

# ── Step 3: Enable in settings.json ──────────────────────────
echo ""
echo "⚙️   Enabling plugin in settings.json..."

ENABLE_ENTRY=$(cat <<JSON
{
  "plugins": {
    "${PLUGIN_NAME}@local": {
      "enabled": true
    }
  }
}
JSON
)

if [ -f "$CLAUDE_SETTINGS_JSON" ]; then
  python3 - "$CLAUDE_SETTINGS_JSON" "$PLUGIN_NAME" <<'PYEOF'
import json, sys

json_file = sys.argv[1]
plugin_name = sys.argv[2]
key = f"{plugin_name}@local"
stale_keys = ("oracle-sql-optimizer@local",)

with open(json_file, "r") as f:
    data = json.load(f)

plugins = data.setdefault("plugins", {})
for stale in stale_keys:
    plugins.pop(stale, None)
plugins[key] = {"enabled": True}

enabled = data.setdefault("enabledPlugins", {})
enabled[key] = True

with open(json_file, "w") as f:
    json.dump(data, f, indent=2)
print(f"    ✓ Merged into {json_file} (plugins + enabledPlugins)")
PYEOF
else
  echo "$ENABLE_ENTRY" > "$CLAUDE_SETTINGS_JSON"
  echo "    ✓ Created $CLAUDE_SETTINGS_JSON"
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "✅  Install complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Cursor IDE (or Cmd/Ctrl+Shift+P → Reload Window)"
echo "  2. Open Cursor Agent chat"
echo "  3. Enable plugin: Cursor Settings → Plugins → socialdevflow-sql-analyzer"
echo "  4. Test in Agent chat (type / and search 'oracle'):"
echo "     Commands: /oracle-analyze  /oracle-convert"
echo "     Or full:  /socialdevflow-sql-analyzer:oracle-analyze"
echo "     Skills:   /oracle-query-analyzer  /oracle-dialect-converter"
echo "  5. Or ask: 'analyze this Oracle query: SELECT * FROM orders'"
echo ""
echo "Updates: git -C \"$PLUGIN_DIR\" pull && bash \"$PLUGIN_DIR/scripts/install-plugin.sh\""
echo ""
