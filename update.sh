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

mkdir -p "$LOG_DIR" || exit 1

log "Update started."
log "Project directory: $PROJECT_DIR"

cd "$PROJECT_DIR" || fail "Could not enter project directory."

log "Pulling latest changes from GitHub."

git pull --ff-only origin "$BRANCH" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    fail "Git pull failed."
fi

log "Git pull completed successfully."

if [ ! -x "$PROJECT_DIR/venv/bin/pip" ]; then
    fail "Virtual environment pip not found at $PROJECT_DIR/venv/bin/pip."
fi

log "Installing Python dependencies."

"$PROJECT_DIR/venv/bin/pip" install -r requirements.txt >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    fail "Dependency installation failed."
fi

log "Dependencies installed successfully."
log "Restarting systemd service: $SERVICE_NAME."

sudo systemctl restart "$SERVICE_NAME" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    fail "Service restart failed."
fi

sleep 2

sudo systemctl is-active --quiet "$SERVICE_NAME"

if [ $? -ne 0 ]; then
    fail "Service is not active after restart."
fi

log "Service is active after restart."
log "Checking local health endpoint."

curl -fsS http://127.0.0.1:8000/health >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    fail "Health check failed."
fi

log "Health check passed."
log "Update completed successfully."
endlog
