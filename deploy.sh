#!/bin/bash
set -euo pipefail
echo '=== ServerWatch Deploy ==='

if ! id serverwatch >/dev/null 2>&1; then
    sudo useradd --system --no-create-home \
      --shell /usr/sbin/nologin serverwatch
    echo '[+] Created serverwatch user'
fi

sudo mkdir -p /var/log/serverwatch
sudo chown serverwatch:serverwatch /var/log/serverwatch
sudo chmod 750 /var/log/serverwatch
echo '[+] Log directory ready'

sudo cp src/serverwatch.sh /usr/local/bin/serverwatch
sudo chown root:serverwatch /usr/local/bin/serverwatch
sudo chmod 750 /usr/local/bin/serverwatch
echo '[+] Script installed'

sudo cp configs/serverwatch.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now serverwatch
echo '[+] Service enabled and started'
echo 'Done. Run: systemctl status serverwatch'
