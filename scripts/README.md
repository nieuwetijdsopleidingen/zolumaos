# scripts/

Installatie- en configuratiescripts voor ZolumaOS.

| Script | Doel |
|--------|------|
| `setup-structure.sh` | Maakt de volledige mappenstructuur aan (idempotent) |
| `install-wine.sh` | Installeert Wine + Winetricks + binfmt_misc registratie |
| `setup-desktop.sh` | Configureert XFCE met macOS-achtige uitstraling + Plank dock |

Alle scripts zijn idempotent — meerdere keren uitvoeren geeft geen fouten.  
Test altijd eerst in een VM (VirtualBox / QEMU) voor uitrol op echte hardware.
