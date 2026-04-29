# CLAUDE.md — Projectinstructies voor Claude Code

## Projectnaam
ZolumaOS: Aangepaste Linux-distributie

## Doel
Een gebruiksvriendelijke Linux-distro bouwen met:
- Wine/Proton standaard geïntegreerd (.exe werkt direct)
- XFCE desktop met macOS/Zorin-achtige interface
- Eigen Cloud Software Store (APT + Flatpak + Wine-apps)
- Automatische installatie via Calamares + cloud-init
- Ondersteuning voor hardware vanaf 2010 (2 GB RAM minimum)

## Technische basis
- Base: Ubuntu 26.04 LTS "Resolute" (amd64 + i386 indien mogelijk)
- Kernel: standaard Ubuntu-kernel + patches oudere hardware
- Desktop: XFCE 4.18+
- Wine: wine-stable + winetricks + binfmt_misc registratie
- Build tool: live-build of cubic voor ISO-aanpassing

## Mappenstructuur
zolumaos/
  config/           # live-build configuratie
  scripts/          # installatie- en configuratiescripts
  store/            # Software Store (frontend + backend)
  ansible/          # uitrolconfiguraties
  docs/             # documentatie
  iso-output/       # gegenereerde ISO-bestanden

## Werkregels voor Claude Code
1. Schrijf altijd herstelbare scripts (idempotent waar mogelijk)
2. Test scripts eerst op een VM, niet direct op host
3. Gebruik Bash voor systeem scripts, Python voor complexe logica
4. Documenteer elke stap in scripts met comments
5. Voeg geen Wine-versie hardcoded in: gebruik wine --version check
6. Bij twijfel: vraag bevestiging voordat je systeembestanden wijzigt

## Huidige fase
FASE 1: Basis distro opzetten en Wine integreren

## Volgende taak
Projectstructuur aangemaakt — Wine-integratiescript en desktop-setup
