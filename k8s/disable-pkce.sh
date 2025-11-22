#!/bin/bash
# Update Keycloak client to disable PKCE requirement

kubectl exec -it keycloak-0 -n fitness-tracker -- /bin/bash << 'EOF'
cd /opt/keycloak/bin

# Login to Keycloak
./kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin123

# Update fitness-tracker-frontend client to disable PKCE
./kcadm.sh update clients/$(./kcadm.sh get clients -r fitness-tracker -q clientId=fitness-tracker-frontend --fields id --format csv --noquotes) -r fitness-tracker -s 'attributes."pkce.code.challenge.method"=""'

echo "PKCE disabled for fitness-tracker-frontend client"
EOF
