#!/bin/bash
set -euo pipefail

# ============================================
# deploy.sh - Deploy or rollback the stack
# Usage:
#   ./scripts/deploy.sh deploy
#   ./scripts/deploy.sh rollback
#   ./scripts/deploy.sh status
#   ./scripts/deploy.sh backup
# ============================================

COMPOSE_FILE="docker-compose.yml"
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_CONTAINER="kamka-devops-intern-db-1"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "ERROR: Docker is not installed or not in PATH"
        exit 1
    fi
}

deploy() {
    log "Starting deployment..."
    check_docker

    if [ ! -f ".env" ]; then
        echo "ERROR: .env file not found. Copy .env.example and fill in the values."
        exit 1
    fi

    log "Pulling latest images..."
    docker compose -f "$COMPOSE_FILE" pull --quiet

    log "Starting services..."
    docker compose -f "$COMPOSE_FILE" up -d --build

    log "Waiting for services to be healthy..."
    sleep 5

    log "Checking service status..."
    docker compose -f "$COMPOSE_FILE" ps

    log "Deployment complete!"
}

rollback() {
    log "Rolling back to previous state..."
    check_docker

    log "Stopping current containers..."
    docker compose -f "$COMPOSE_FILE" down

    log "Restarting with existing images (no rebuild)..."
    docker compose -f "$COMPOSE_FILE" up -d

    log "Rollback complete!"
    docker compose -f "$COMPOSE_FILE" ps
}

status() {
    log "Checking stack status..."
    check_docker
    docker compose -f "$COMPOSE_FILE" ps
    echo ""
    log "Container health:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

backup() {
    log "Starting database backup..."
    check_docker

    mkdir -p "$BACKUP_DIR"

    BACKUP_FILE="$BACKUP_DIR/todos_backup_$DATE.sql"

    log "Dumping database to $BACKUP_FILE..."
    docker exec "$DB_CONTAINER" pg_dump -U postgres todos > "$BACKUP_FILE"

    if [ -f "$BACKUP_FILE" ]; then
        log "Backup successful: $BACKUP_FILE"
        ls -lh "$BACKUP_FILE"
    else
        echo "ERROR: Backup file not created"
        exit 1
    fi
}

# ---- Main ----
COMMAND="${1:-help}"

case "$COMMAND" in
    deploy)   deploy ;;
    rollback) rollback ;;
    status)   status ;;
    backup)   backup ;;
    *)
        echo "Usage: $0 {deploy|rollback|status|backup}"
        echo ""
        echo "  deploy    Build and start all services"
        echo "  rollback  Restart services without rebuild"
        echo "  status    Show current stack status"
        echo "  backup    Backup the PostgreSQL database"
        exit 1
        ;;
esac