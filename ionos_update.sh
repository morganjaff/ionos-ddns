#!/bin/bash
set -e

# ================= CONFIG =================
if [[ -z "$IONOS_API_KEY" ]]; then
  echo $(date '+%Y-%m-%d %H:%M:%S')" : [ERREUR] Variable IONOS_API_KEY non définie"
  exit 1
fi

if [[ -z "$IONOS_DOMAINS" ]]; then
  echo $(date '+%Y-%m-%d %H:%M:%S')" : [ERREUR] Variable IONOS_DOMAINS non définie (liste séparée par des virgules)"
  exit 1
fi

# IONOS_DOMAINS attendue sous la forme : "touki.eu,www.touki.eu,*.touki.eu"
IFS=',' read -ra DOMAINS <<< "$IONOS_DOMAINS"

TTL="${IONOS_TTL:-60}"
API_URL="https://api.hosting.ionos.com/dns/v1"
# ==========================================

echo
echo $(date '+%Y-%m-%d %H:%M:%S')" : [START] Synchronisation "

# ===== IP PUBLIQUE =====
PUBLIC_IP=$(curl -s https://api.ipify.org)

if [[ -z "$PUBLIC_IP" ]]; then
  echo $(date '+%Y-%m-%d %H:%M:%S')" : [ERREUR] Impossible de récupérer l'IP publique"
  exit 1
fi

echo $(date '+%Y-%m-%d %H:%M:%S')" : [INFO] IP publique détectée : $PUBLIC_IP"

# ===== RÉCUPÉRATION DES ZONES =====
echo $(date '+%Y-%m-%d %H:%M:%S')" : [INFO] Récupération des zones DNS..."
ZONES=$(curl -s \
  -H "X-API-Key: $IONOS_API_KEY" \
  "$API_URL/zones")

# ===== BOUCLE DOMAINES =====
for DOMAIN in "${DOMAINS[@]}"; do
  # Retire les espaces éventuels autour du domaine (ex: "touki.eu, www.touki.eu")
  DOMAIN="$(echo "$DOMAIN" | xargs)"

  echo $(date '+%Y-%m-%d %H:%M:%S')" : [INFO] Traitement : $DOMAIN"

  # Trouver la zone correspondante
  ZONE_ID=$(echo "$ZONES" | jq -r \
    --arg domain "$DOMAIN" \
    '.[] | select(.name) | .id' | head -n1)

  if [[ -z "$ZONE_ID" ]]; then
    echo $(date '+%Y-%m-%d %H:%M:%S')" : [WARN] Aucune zone trouvée pour $DOMAIN"
    continue
  fi

  # Récupérer les enregistrements de la zone
  RECORD=$(curl -s \
    -H "X-API-Key: $IONOS_API_KEY" \
    "$API_URL/zones/$ZONE_ID" \
    | jq -r \
      --arg name "$DOMAIN" \
      '.records[] | select(.name == $name and .type == "A")')

  if [[ -z "$RECORD" ]]; then
    echo $(date '+%Y-%m-%d %H:%M:%S')" : [WARN] Aucun enregistrement A trouvé pour $DOMAIN"
    continue
  fi

  RECORD_ID=$(echo "$RECORD" | jq -r '.id')
  CURRENT_IP=$(echo "$RECORD" | jq -r '.content')

  if [[ "$CURRENT_IP" == "$PUBLIC_IP" ]]; then
    echo $(date '+%Y-%m-%d %H:%M:%S')" : [OK] IP déjà à jour ($CURRENT_IP)"
    continue
  fi

  echo $(date '+%Y-%m-%d %H:%M:%S')" : [UPDATE] $DOMAIN : $CURRENT_IP → $PUBLIC_IP"

  curl -s -X PUT \
    -H "X-API-Key: $IONOS_API_KEY" \
    -H "Content-Type: application/json" \
    "$API_URL/zones/$ZONE_ID/records/$RECORD_ID" \
    -d "{
      \"name\": \"$DOMAIN\",
      \"type\": \"A\",
      \"content\": \"$PUBLIC_IP\",
      \"ttl\": $TTL
    }" > /dev/null

  echo $(date '+%Y-%m-%d %H:%M:%S')" : [DONE] $DOMAIN mis à jour"

done

echo $(date '+%Y-%m-%d %H:%M:%S')" : [FIN] Synchronisation terminée"
