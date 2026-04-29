# ansible/

Ansible-configuraties voor automatische uitrol van ZolumaOS op meerdere machines.

## Bestanden

| Bestand | Omschrijving |
|---------|--------------|
| `site.yml` | Hoofd-playbook — voert alle rollen uit |
| `inventory.yml` | Lijst van doelmachines |
| `roles/common/` | Basis systeemconfiguratie (tijdzone, locale, updates) |
| `roles/wine/` | Wine-installatie via install-wine.sh |
| `roles/desktop/` | XFCE desktop configuratie |
| `roles/store/` | Software Store installatie en configuratie |

## Uitvoeren

```bash
# Alle machines configureren
ansible-playbook -i inventory.yml site.yml

# Alleen Wine installeren
ansible-playbook -i inventory.yml site.yml --tags wine

# Dry-run (geen wijzigingen)
ansible-playbook -i inventory.yml site.yml --check
```
