#!/usr/bin/env bash
# setup-desktop.sh — Configureert XFCE met macOS/ZolumaOS-achtige uitstraling.
# Installeert: Plank dock, WhiteSur GTK-theme, Papirus iconen.
# Idempotent: meerdere keren uitvoeren is veilig.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Root-check ──────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    error "Dit script vereist root-rechten. Gebruik: sudo bash setup-desktop.sh"
fi

# ── XFCE installeren (als nog niet aanwezig) ─────────────────
info "XFCE desktop omgeving controleren..."
if ! command -v xfce4-session &>/dev/null; then
    info "XFCE installeren..."
    apt-get update -qq
    apt-get install -y \
        xfce4 \
        xfce4-goodies \
        xfce4-terminal \
        xfce4-power-manager \
        thunar \
        thunar-volman \
        gvfs-backends \
        lightdm \
        lightdm-gtk-greeter
    info "XFCE geïnstalleerd"
else
    info "XFCE was al geïnstalleerd"
fi

# ── Plank dock installeren ───────────────────────────────────
# Plank is een macOS-achtig dock dat onderaan het scherm staat.
info "Plank dock installeren..."
if ! command -v plank &>/dev/null; then
    apt-get install -y plank
    info "Plank geïnstalleerd"
else
    info "Plank was al geïnstalleerd"
fi

# ── Afhankelijkheden voor theme-installatie ──────────────────
info "Thema-afhankelijkheden installeren..."
apt-get install -y \
    git \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    sassc \
    libglib2.0-dev-bin 2>/dev/null || true

# ── WhiteSur GTK-theme installeren ──────────────────────────
# WhiteSur geeft XFCE een moderne macOS Big Sur-achtige uitstraling.
THEMES_DIR="/usr/share/themes"
WHITESUR_DIR="$THEMES_DIR/WhiteSur-Light"
WHITESUR_TMP="/tmp/WhiteSur-gtk-theme"

info "WhiteSur GTK-theme installeren..."
if [ ! -d "$WHITESUR_DIR" ]; then
    rm -rf "$WHITESUR_TMP"
    git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$WHITESUR_TMP"
    cd "$WHITESUR_TMP"
    bash install.sh --dest "$THEMES_DIR" --name WhiteSur --color light
    cd -
    rm -rf "$WHITESUR_TMP"
    info "WhiteSur theme geïnstalleerd in $THEMES_DIR"
else
    info "WhiteSur theme was al aanwezig"
fi

# ── Papirus iconen installeren ───────────────────────────────
# Papirus is een modern iconenpakket dat goed past bij de ZolumaOS-stijl.
info "Papirus iconenpakket installeren..."
if [ ! -d "/usr/share/icons/Papirus" ]; then
    # Officiële Papirus PPA (Ubuntu) of directe download (Debian)
    if command -v add-apt-repository &>/dev/null; then
        add-apt-repository -y ppa:papirus/papirus 2>/dev/null || true
        apt-get update -qq
    fi
    apt-get install -y papirus-icon-theme 2>/dev/null || {
        # Fallback: installeer via snap of handmatig
        PAPIRUS_TMP="/tmp/papirus-icon-theme"
        rm -rf "$PAPIRUS_TMP"
        git clone --depth 1 https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git "$PAPIRUS_TMP"
        bash "$PAPIRUS_TMP/install.sh"
        rm -rf "$PAPIRUS_TMP"
    }
    info "Papirus iconen geïnstalleerd"
else
    info "Papirus iconen waren al aanwezig"
fi

# ── XFCE-instellingen toepassen via xfconf-query ────────────
# xfconf-query werkt per gebruiker — wordt uitgevoerd als de ingelogde gebruiker.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

apply_xfconf() {
    # Uitvoeren als de echte gebruiker (niet root)
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$REAL_USER")/bus" \
        xfconf-query "$@" 2>/dev/null || true
}

info "XFCE configureren voor gebruiker: $REAL_USER"

# GTK-theme instellen
apply_xfconf -c xsettings -p /Net/ThemeName -s "WhiteSur-Light"
# Icoontheme instellen
apply_xfconf -c xsettings -p /Net/IconThemeName -s "Papirus"
# Vensterbeheerder-theme
apply_xfconf -c xfwm4 -p /general/theme -s "WhiteSur-Light"
# Lettertype
apply_xfconf -c xsettings -p /Gtk/FontName -s "Inter 10"
apply_xfconf -c xfwm4 -p /general/title_font -s "Inter Bold 9"

# XFCE-panel configureren: één paneel bovenaan (macOS-stijl menubalk)
# Paneel 1 bovenaan instellen
apply_xfconf -c xfce4-panel -p /panels/panel-1/position -s "p=6;x=0;y=0"
apply_xfconf -c xfce4-panel -p /panels/panel-1/size -s 28
apply_xfconf -c xfce4-panel -p /panels/panel-1/position-locked -s true

info "XFCE instellingen toegepast"

# ── Plank configureren en autostart instellen ────────────────
info "Plank dock configureren als autostart..."

AUTOSTART_DIR="$REAL_HOME/.config/autostart"
PLANK_DESKTOP="$AUTOSTART_DIR/plank.desktop"

sudo -u "$REAL_USER" mkdir -p "$AUTOSTART_DIR"

if [ ! -f "$PLANK_DESKTOP" ]; then
    sudo -u "$REAL_USER" tee "$PLANK_DESKTOP" > /dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=ZolumaOS dock
Exec=plank
Icon=plank
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF
    info "Plank autostart aangemaakt: $PLANK_DESKTOP"
else
    info "Plank autostart was al aanwezig"
fi

# Plank-configuratie instellen (theme + positie)
PLANK_CONF_DIR="$REAL_HOME/.config/plank/dock1"
sudo -u "$REAL_USER" mkdir -p "$PLANK_CONF_DIR"

PLANK_CONF="$PLANK_CONF_DIR/settings"
if [ ! -f "$PLANK_CONF" ]; then
    sudo -u "$REAL_USER" tee "$PLANK_CONF" > /dev/null <<'EOF'
[PlankDockPreferences]
#Whether to show only windows of the current workspace.
CurrentWorkspaceOnly=false
#The name of the dock's theme to use.
Theme=Matte
#The type of icon alignment to use.
Alignment=3
#The monitor to display the dock on. Use -1 to display on the primary monitor.
Monitor=-1
#Whether the dock is locked.
LockItems=false
#How long to make the dock.
MaxIconSize=48
#The position of the dock on the monitor.
Position=3
#Whether to show the dock.
HideMode=1
#The delay time to wait before hiding the dock.
HideDelay=0
#The delay time to wait before showing the dock.
ShowDelay=0
#Whether zoom is enabled.
ZoomEnabled=true
#The amount to zoom icons.
ZoomPercent=150
EOF
    info "Plank configuratie aangemaakt"
else
    info "Plank configuratie was al aanwezig"
fi

# ── LightDM achtergrond instellen ────────────────────────────
GREETER_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"
if [ -f "$GREETER_CONF" ]; then
    info "LightDM greeter thema instellen..."
    # Stel theme in als het nog niet gezet is
    if ! grep -q "theme-name.*WhiteSur" "$GREETER_CONF" 2>/dev/null; then
        cat >> "$GREETER_CONF" <<'EOF'

# ZolumaOS desktop theme
[greeter]
theme-name = WhiteSur-Light
icon-theme-name = Papirus
font-name = Inter 10
EOF
        info "LightDM theme ingesteld"
    fi
fi

# ── Firefox user-agent instellen (ZolumaOS Store detectie) ──
info "Firefox user-agent configureren voor ZolumaOS Store..."
FF_PROFILE_DIR=$(find "$REAL_HOME/.mozilla/firefox" -name "*.default-release" -type d 2>/dev/null | head -1)
if [ -n "$FF_PROFILE_DIR" ]; then
    FF_PREFS="$FF_PROFILE_DIR/user.js"
    if ! grep -q "ZolumaOS" "$FF_PREFS" 2>/dev/null; then
        sudo -u "$REAL_USER" tee -a "$FF_PREFS" > /dev/null <<'EOF'
// ZolumaOS Store identificatie
user_pref("general.useragent.override", "Mozilla/5.0 (X11; Linux aarch64; ZolumaOS/1.0) Gecko/20100101 Firefox/124.0");
EOF
        info "Firefox user-agent ingesteld"
    fi
else
    # Globale Firefox policy als fallback
    mkdir -p /etc/firefox/policies
    cat > /etc/firefox/policies/policies.json <<'EOF'
{
  "policies": {
    "Preferences": {
      "general.useragent.override": {
        "Value": "Mozilla/5.0 (X11; Linux aarch64; ZolumaOS/1.0) Gecko/20100101 Firefox/124.0",
        "Status": "locked"
      }
    }
  }
}
EOF
    info "Firefox policy ingesteld (globaal)"
fi

# ── Samenvatting ─────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "  ZolumaOS desktop configuratie klaar"
echo "════════════════════════════════════════"
echo "  GTK-theme  : WhiteSur-Light"
echo "  Iconen     : Papirus"
echo "  Dock       : Plank (start automatisch)"
echo "  Panel      : XFCE bovenaan"
echo ""
echo "  Log uit en weer in om alle wijzigingen"
echo "  te activeren."
echo "════════════════════════════════════════"
