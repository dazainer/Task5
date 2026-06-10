#!/bin/bash

# update.sh
# Usage: ./update.sh
# Pulls the latest code from GitHub, updates Python dependencies,
# restarts the FastAPI systemd service, and logs the result.

set -u

SERVICE_NAME="fastapi-task"
BRANCH="main"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/update.log"
SERVICE_CHECK_RETRIES=10
HEALTH_CHECK_RETRIES=10

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

endlog() {
    echo "--------------------------END OF UPDATE--------------------------" >> "$LOG_FILE"
}

fail() {
    log "UPDATE FAILED: $1"
    endlog
    exit 1
}

checkstatus() {
    if [ "$1" -ne 0 ]; then
        fail "$2"
    fi
}

wait_for_service() {
    local attempt=1

    while [ "$attempt" -le "$SERVICE_CHECK_RETRIES" ]; do
        if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
            return 0
        fi

        log "Service is not active yet. Retry $attempt/$SERVICE_CHECK_RETRIES."
        sleep 1
        attempt=$((attempt + 1))
    done

    return 1
}

wait_for_health() {
    local attempt=1

    while [ "$attempt" -le "$HEALTH_CHECK_RETRIES" ]; do
        if curl -fsS http://127.0.0.1:8000/health >> "$LOG_FILE" 2>&1; then
            return 0
        fi

        log "Health check is not ready yet. Retry $attempt/$HEALTH_CHECK_RETRIES."
        sleep 1
        attempt=$((attempt + 1))
    done

    return 1
}

mkdir -p "$LOG_DIR" || exit 1

log "Update started."
log "Project directory: $PROJECT_DIR"

cd "$PROJECT_DIR" || fail "Could not enter project directory."

log "Pulling latest changes from GitHub."

git pull --ff-only origin "$BRANCH" >> "$LOG_FILE" 2>&1


checkstatus $? "Git pull failed."


log "Git pull completed successfully."

if [ ! -x "$PROJECT_DIR/venv/bin/pip" ]; then
    fail "Virtual environment pip not found at $PROJECT_DIR/venv/bin/pip."
fi

log "Installing Python dependencies."

"$PROJECT_DIR/venv/bin/pip" install -r requirements.txt >> "$LOG_FILE" 2>&1


checkstatus $? "Dependency installation failed."


log "Dependencies installed successfully."
log "Restarting systemd service: $SERVICE_NAME."

sudo systemctl restart "$SERVICE_NAME" >> "$LOG_FILE" 2>&1


checkstatus $? "Service restart failed."


log "Waiting for service to become active."

wait_for_service

checkstatus $? "Service is not active after restart."


log "Service is active after restart."
log "Checking local health endpoint."

wait_for_health


checkstatus $? "Health check failed."


log "Health check passed."
log "Update completed successfully."
endlog
