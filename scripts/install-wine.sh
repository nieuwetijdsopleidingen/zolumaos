#!/usr/bin/env bash
# install-wine.sh — Installeert Wine + Winetricks + binfmt_misc voor ZolumaOS.
# Vereist: Ubuntu 22.04/24.04/26.04 LTS of Debian 12, root-rechten, x86_64 architectuur.
# Idempotent: meerdere keren uitvoeren is veilig.

set -euo pipefail

# ── Kleuruitvoer ────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Root-check ──────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    error "Dit script vereist root-rechten. Gebruik: sudo bash install-wine.sh"
fi

# ── Architectuur-check ──────────────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    error "Wine vereist x86_64. Dit systeem draait op $ARCH.\nWine werkt niet op ARM — gebruik dit script op een x86_64 machine."
fi

# ── OS-check ────────────────────────────────────────────────
info "Besturingssysteem controleren..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_VERSION="${VERSION_ID:-}"
else
    error "Kan /etc/os-release niet lezen. Wordt dit systeem ondersteund?"
fi

case "$OS_ID" in
    ubuntu)
        if [[ "$OS_VERSION" != "22.04" && "$OS_VERSION" != "24.04" && "$OS_VERSION" != "26.04" ]]; then
            warning "Getest op Ubuntu 22.04/24.04/26.04. Je draait $OS_VERSION — ga op eigen risico verder."
        fi
        CODENAME="${UBUNTU_CODENAME:-resolute}"
        ;;
    debian)
        if [[ "$OS_VERSION" != "12" && "$OS_VERSION" != "11" ]]; then
            warning "Getest op Debian 11/12. Je draait $OS_VERSION — ga op eigen risico verder."
        fi
        CODENAME="${VERSION_CODENAME:-bookworm}"
        ;;
    *)
        error "Niet-ondersteund besturingssysteem: $OS_ID. Gebruik Ubuntu 22.04 of Debian 12."
        ;;
esac
info "Systeem: $OS_ID $OS_VERSION ($CODENAME) — OK"

# ── 32-bit architectuur inschakelen (nodig voor Wine) ───────
info "32-bit (i386) architectuur inschakelen..."
if ! dpkg --print-foreign-architectures | grep -q i386; then
    dpkg --add-architecture i386
    apt-get update -qq
    info "i386 toegevoegd"
else
    info "i386 was al ingeschakeld"
fi

# ── WineHQ repository toevoegen ─────────────────────────────
WINE_KEY="/etc/apt/keyrings/winehq-archive.key"
WINE_LIST="/etc/apt/sources.list.d/winehq-${CODENAME}.sources"

if [ ! -f "$WINE_KEY" ]; then
    info "WineHQ GPG-sleutel installeren..."
    mkdir -p /etc/apt/keyrings
    wget -qO "$WINE_KEY" https://dl.winehq.org/wine-builds/winehq.key
    info "GPG-sleutel opgeslagen: $WINE_KEY"
else
    info "WineHQ GPG-sleutel was al aanwezig"
fi

if [ ! -f "$WINE_LIST" ]; then
    info "WineHQ repository toevoegen voor $CODENAME..."
    wget -qO "$WINE_LIST" \
        "https://dl.winehq.org/wine-builds/${OS_ID}/dists/${CODENAME}/winehq-${CODENAME}.sources"
    apt-get update -qq
    info "Repository toegevoegd"
else
    info "WineHQ repository was al aanwezig"
fi

# ── Wine installeren ─────────────────────────────────────────
info "Wine stable installeren..."
if ! command -v wine &>/dev/null; then
    apt-get install -y --install-recommends winehq-stable
    info "Wine geïnstalleerd: $(wine --version)"
else
    WINE_VER=$(wine --version)
    info "Wine was al geïnstalleerd: $WINE_VER"
fi

# ── Winetricks installeren ───────────────────────────────────
info "Winetricks installeren..."
if ! command -v winetricks &>/dev/null; then
    apt-get install -y winetricks
    info "Winetricks geïnstalleerd: $(winetricks --version)"
else
    info "Winetricks was al geïnstalleerd"
fi

# ── binfmt_misc instellen voor .exe-bestanden ───────────────
# Hiermee kan de kernel .exe-bestanden direct via Wine uitvoeren,
# zonder dat de gebruiker 'wine' hoeft te typen.
BINFMT_CONF="/etc/binfmt.d/wine.conf"

info "binfmt_misc configureren voor .exe-bestanden..."
if [ ! -f "$BINFMT_CONF" ]; then
    cat > "$BINFMT_CONF" <<'EOF'
# ZolumaOS: laat de kernel .exe-bestanden automatisch via Wine uitvoeren.
# Formaat: :name:type:offset:magic:mask:interpreter:flags
:windows:M::MZ::/usr/bin/wine:
EOF
    # binfmt_misc direct activeren (geen herstart nodig)
    systemctl restart systemd-binfmt || true
    info "binfmt_misc geconfigureerd: $BINFMT_CONF"
else
    info "binfmt_misc was al geconfigureerd"
fi

# Controleer of binfmt_misc actief is
if grep -q windows /proc/sys/fs/binfmt_misc/ 2>/dev/null || \
   ls /proc/sys/fs/binfmt_misc/windows &>/dev/null 2>&1; then
    info "binfmt_misc actief — .exe-bestanden worden automatisch herkend"
else
    warning "binfmt_misc-activering niet bevestigd. Herstart het systeem om dit te voltooien."
fi

# ── Snelle functionaliteitstest ──────────────────────────────
info "Wine-installatie testen..."
TEST_DIR=$(mktemp -d)
TEST_OUTPUT="$TEST_DIR/wine-test.txt"

# wine --version schrijft versie naar stdout — voldoende als basistest
wine --version > "$TEST_OUTPUT" 2>&1 && {
    info "Wine-test geslaagd: $(cat "$TEST_OUTPUT")"
} || {
    warning "wine --version gaf een fout. Controleer de installatie handmatig."
}

rm -rf "$TEST_DIR"

# ── Samenvatting ─────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "  ZolumaOS Wine-integratie voltooid"
echo "════════════════════════════════════════"
echo "  Wine versie : $(wine --version 2>/dev/null || echo 'onbekend')"
echo "  binfmt conf : $BINFMT_CONF"
echo "  .exe-bestanden worden automatisch via Wine uitgevoerd."
echo ""
echo "  Tip: test met een Windows-installer door erop te dubbelklikken"
echo "  of via: wine /pad/naar/programma.exe"
echo "════════════════════════════════════════"
