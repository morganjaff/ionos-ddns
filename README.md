# ionos-ddns

🇫🇷 [Français](#français) · 🇬🇧 [English](#english)

---

## Français

Client Dynamic DNS minimaliste pour l'API IONOS. Met à jour un ou plusieurs
enregistrements `A` vers l'IP publique courante, à intervalle régulier.

### Fonctionnement

- `ionos_update.sh` récupère l'IP publique via `api.ipify.org`, compare avec
  l'enregistrement `A` existant sur IONOS pour chaque domaine listé, et met à
  jour uniquement si nécessaire.
- `entrypoint.sh` configure un cron interne au conteneur et lance une
  première synchronisation immédiate au démarrage.

### Déploiement sur Unraid

1. Place `my-ionos-ddns.xml` dans `/boot/config/plugins/dockerMan/templates-user/`.
2. Dans Unraid : **Docker → Add Container**, sélectionne le template
   `ionos-ddns` dans la liste déroulante.
3. Renseigne ta clé API IONOS et vérifie la liste de domaines
   (`IONOS_DOMAINS`, séparés par des virgules, espaces tolérés).
4. **Apply** — Unraid télécharge directement l'image depuis GitHub Container
   Registry.

### Variables d'environnement

| Variable | Requis | Défaut | Description |
|---|---|---|---|
| `IONOS_API_KEY` | oui | — | Clé API IONOS (format `prefix.secret`) |
| `IONOS_DOMAINS` | oui | — | Domaines à synchroniser, séparés par des virgules |
| `CRON_SCHEDULE` | non | `*/30 * * * *` | Intervalle de synchronisation |
| `IONOS_TTL` | non | `60` | TTL des enregistrements DNS (secondes) |
| `TZ` | non | `UTC` | Fuseau horaire pour l'horodatage des logs |

---

## English

Minimalist Dynamic DNS client for the IONOS API. Updates one or more `A`
records to the current public IP address, at a regular interval.

### How it works

- `ionos_update.sh` fetches the public IP via `api.ipify.org`, compares it
  with the existing `A` record on IONOS for each listed domain, and updates
  it only when necessary.
- `entrypoint.sh` configures an internal cron job inside the container and
  triggers an immediate first sync on startup.

### Deploying on Unraid

1. Place `my-ionos-ddns.xml` in `/boot/config/plugins/dockerMan/templates-user/`.
2. In Unraid: **Docker → Add Container**, select the `ionos-ddns` template
   from the dropdown list.
3. Enter your IONOS API key and check the domain list (`IONOS_DOMAINS`,
   comma-separated, spaces tolerated).
4. **Apply** — Unraid pulls the image directly from GitHub Container
   Registry.

### Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `IONOS_API_KEY` | yes | — | IONOS API key (`prefix.secret` format) |
| `IONOS_DOMAINS` | yes | — | Comma-separated list of domains to sync |
| `CRON_SCHEDULE` | no | `*/30 * * * *` | Sync interval (cron syntax) |
| `IONOS_TTL` | no | `60` | DNS record TTL (seconds) |
| `TZ` | no | `UTC` | Timezone used for log timestamps |

