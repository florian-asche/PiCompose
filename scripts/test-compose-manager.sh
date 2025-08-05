#!/bin/bash
# Test-Script für den Docker-Compose-Manager

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Erstelle temporäre Testumgebung
TEST_DIR=$(mktemp -d)
log_info "Erstelle temporäre Testumgebung in $TEST_DIR"

# Erstelle Testverzeichnisse und -dateien
mkdir -p $TEST_DIR/compose/test-project
cat > $TEST_DIR/compose/test-project/docker-compose.yml << EOF
version: '3'

services:
  hello-world:
    image: hello-world
    restart: "no"
EOF

cat > $TEST_DIR/boot/compose/test-project/picompose.conf << EOF
# Configure if piCompose should run on boot
# When it runs without image pull, it does a docker compose down and up.
BOOT_ENABLED=true

# Configure if piCompose should update the docker image on boot
# BOOT_ENABLED needs to be true
BOOT_IMAGE_PULL=true

# Configure if piCompose should run periodically via cron
# When it runs without image pull, it does a docker compose down and up.
CRON_ENABLED=true

# Cron schedule for automatic re-deployments
# Format: Minute Hour Day Month Weekday
# Examples:
# "0 4 * * *"     - Every day at 4 AM
# "0 */6 * * *"   - Every 6 hours
# "0 0 * * 0"     - Every Sunday at midnight
CRON_SCHEDULE="0 4 * * *"

# Configure if piCompose should update the docker image on cron run
# CRON_ENABLED needs to be true
CRON_IMAGE_PULL=true
EOF

# Kopiere das Compose-Manager-Skript
cp stage-picompose/00-boot-scripts/files/compose-manager.sh $TEST_DIR/

# Passe das Skript für Testzwecke an
sed -i 's|base_path=.*|base_path="/compose"|g' $TEST_DIR/compose-manager.sh
chmod +x $TEST_DIR/compose-manager.sh

# Führe den Test aus
log_info "Starte Test des Compose-Manager-Skripts..."
if docker ps &>/dev/null; then
    cd $TEST_DIR && ./compose-manager.sh
    TEST_EXIT_CODE=$?
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        log_info "Test erfolgreich abgeschlossen!"
    else
        log_error "Test fehlgeschlagen mit Exit-Code $TEST_EXIT_CODE"
    fi
else
    log_warn "Docker ist nicht verfügbar. Der Test kann nicht durchgeführt werden."
    log_info "Stelle sicher, dass Docker installiert und gestartet ist, bevor du den Test ausführst."
fi

# Bereinige die Testumgebung
log_info "Bereinige Testumgebung..."
rm -rf $TEST_DIR

log_info "Test abgeschlossen."
