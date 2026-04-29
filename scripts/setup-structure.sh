#!/usr/bin/env bash
# setup-structure.sh — Maakt de volledige ZolumaOS mappenstructuur aan.
# Idempotent: meerdere keren uitvoeren is veilig.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

echo "==> ZolumaOS projectstructuur aanmaken in: $ROOT"

# Alle mappen aanmaken (mkdir -p is idempotent)
dirs=(
    "config/auto"
    "config/config/packages.chroot"
    "config/config/includes.chroot"
    "config/config/hooks"
    "scripts"
    "store/frontend/src"
    "store/frontend/public"
    "store/backend/db"
    "store/backend/routes"
    "ansible/roles/common/tasks"
    "ansible/roles/wine/tasks"
    "ansible/roles/desktop/tasks"
    "ansible/roles/store/tasks"
    "docs"
    "iso-output"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$ROOT/$dir"
    echo "   [ok] $dir"
done

# .gitignore aanmaken als die nog niet bestaat
GITIGNORE="$ROOT/.gitignore"
if [ ! -f "$GITIGNORE" ]; then
    cat > "$GITIGNORE" <<'EOF'
iso-output/
store/backend/db/store.db
store/backend/node_modules/
store/frontend/node_modules/
store/frontend/build/
*.log
.env
EOF
    echo "   [ok] .gitignore aangemaakt"
fi

echo ""
echo "==> Structuur klaar."
