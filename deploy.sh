#!/bin/bash
set -e

PACKAGE="$1"
DEPLOY="/var/www/famm-portal"
BACKUP="/var/backups/famm-portal/$(date +%Y%m%d-%H%M%S)"

test -f "$PACKAGE"

mkdir -p "$BACKUP"
cp -a "$DEPLOY/." "$BACKUP/" 2>/dev/null || true

find "$DEPLOY" -mindepth 1 -maxdepth 1 -delete

tar -xzf "$PACKAGE" -C "$DEPLOY"

if curl --fail --silent http://localhost/ >/dev/null; then
    echo "Deployment successful"
    exit 0
fi

find "$DEPLOY" -mindepth 1 -maxdepth 1 -delete
cp -a "$BACKUP/." "$DEPLOY/"

echo "Health check failed; rollback completed"
exit 1
