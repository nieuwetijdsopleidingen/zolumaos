# ZolumaOS

**Versie:** 0.1 | **Jaar:** 2026  
**Auteur:** Henk Riem — NTO Business

Een gebruiksvriendelijke Linux-distributie op Ubuntu 22.04 LTS-basis met:
- Ingebakken Wine/Proton — .exe-bestanden werken direct
- XFCE desktop met moderne macOS/Zorin-achtige uitstraling
- Eigen Cloud Software Store (APT + Flatpak + Wine-apps)
- Minimale systeemeisen: 2 GB RAM, CPU 2010+

## Mappenstructuur

| Map | Inhoud |
|-----|--------|
| `config/` | live-build configuratie voor ISO-aanpassing |
| `scripts/` | installatie- en configuratiescripts |
| `store/` | Software Store frontend en backend |
| `ansible/` | uitrolconfiguraties voor meerdere machines |
| `docs/` | projectdocumentatie |
| `iso-output/` | gegenereerde ISO-bestanden (niet in git) |

## Snelstart

```bash
# 1. Projectstructuur aanmaken (idempotent)
bash scripts/setup-structure.sh

# 2. Wine integreren (Ubuntu 22.04 / Debian 12 vereist)
sudo bash scripts/install-wine.sh

# 3. Desktop configureren
bash scripts/setup-desktop.sh

# 4. Store backend starten
cd store/backend && npm install && npm start
```

## Fasen

- **Fase 1** ✅ Basis distro + Wine-integratie + Desktop
- **Fase 2** 🔄 Software Store (frontend + backend)
- **Fase 3** ⬜ Cloud-uitrol via Ansible
- **Fase 4** ⬜ ISO finaliseren + documentatie

## Licentie
© Nieuwetijds Opleidingen | Henk Riem | Zoetermeer | 2026
