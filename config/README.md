# config/

Live-build configuratie voor de ZolumaOS ISO.

Bevat alle bestanden die live-build nodig heeft om een bootbare ISO te genereren:
- `auto/` — live-build auto-scripts (config, clean, build)
- `config/packages.chroot/` — lijst met te installeren pakketten
- `config/includes.chroot/` — bestanden die 1-op-1 naar het rootbestandssysteem gaan
- `config/hooks/` — scripts die tijdens de build worden uitgevoerd

Gebruik: `lb build` vanuit deze map (vereist live-build op een Debian/Ubuntu-systeem).
