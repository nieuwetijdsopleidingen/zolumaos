#!/bin/sh
# Minimale syslinux/isolinux setup zonder Ubuntu-specifieke thema pakketten.
# Vervangt lb_binary_syslinux in de live-build pipeline.
echo "P: Syslinux installeren (zonder Ubuntu-themas)..."
export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends syslinux-common isolinux syslinux-utils 2>/dev/null || true

mkdir -p binary/isolinux

[ -f /usr/lib/ISOLINUX/isolinux.bin ] && cp /usr/lib/ISOLINUX/isolinux.bin binary/isolinux/ || true
[ -f /usr/lib/syslinux/isolinux.bin ] && cp /usr/lib/syslinux/isolinux.bin binary/isolinux/ || true

find /usr/lib/syslinux/modules/bios/ -name "*.c32" -exec cp {} binary/isolinux/ \; 2>/dev/null || true

printf "DEFAULT live\nLABEL live\n  KERNEL /live/vmlinuz\n  APPEND initrd=/live/initrd.img boot=live components locales=nl_NL.UTF-8 keyboard-layouts=nl timezone=Europe/Amsterdam\n" > binary/isolinux/isolinux.cfg

echo "P: Isolinux minimaal geconfigureerd"
