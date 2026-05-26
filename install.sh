#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Bitte als root ausführen (sudo ./install.sh)"
  exit 1
fi

echo "=== Installiere pyarc-milter (Debian 12/13 konform) ==="

# 1. System-Abhängigkeiten installieren (inklusive python3-venv)
echo "--> Installiere System-Abhängigkeiten..."
apt-get update && apt-get install -y libmilter-dev python3-dev build-essential python3-venv

# 2. Virtuelle Python-Umgebung erstellen (Kein pip-Meckern mehr!)
echo "--> Erstelle isolierte virtuelle Umgebung..."
mkdir -p /usr/share/pyarc-venv
python3 -m venv /usr/share/pyarc-venv

# 3. Pakete innerhalb der venv installieren
echo "--> Installiere Python-Bibliotheken in die venv..."
/usr/share/pyarc-venv/bin/pip install --upgrade pip
/usr/share/pyarc-venv/bin/pip install pymilter dkimpy authres cryptography

# 4. Ordnerstrukturen anlegen
echo "--> Erstelle Verzeichnisse..."
mkdir -p /etc/pyarc/certs
mkdir -p /var/log/pyarc

# 5. Skripte kopieren
echo "--> Kopiere Skripte..."
cp usr/local/bin/pyarc-milter /usr/local/bin/
cp usr/local/bin/pyarc-gen /usr/local/bin/
chmod +x /usr/local/bin/pyarc-milter
chmod +x /usr/local/bin/pyarc-gen
mkdir -p /var/log/pyarc
touch /var/log/pyarc/pyarc.log



# Config-Template kopieren falls nicht vorhanden
if [ ! -f /etc/pyarc/milter.conf ]; then
    cp etc/pyarc/milter.conf.template /etc/pyarc/milter.conf
    echo "✔ Standard-Konfiguration unter /etc/pyarc/milter.conf angelegt."
fi

# Rechte für Postfix anpassen
chown -R postfix:postfix /etc/pyarc
chown -R postfix:postfix /var/log/pyarc
chmod 750 /etc/pyarc
chmod 755 /var/log/pyarc
chmod 640 /var/log/pyarc/pyarc.log

# 6. Systemd Service anpassen und erstellen
echo "--> Erstelle Systemd-Service..."
cat <<EOF > /etc/systemd/system/pyarc-milter.service
[Unit]
Description=Custom Postfix ARC Milter
After=network.target

[Service]
Type=simple
# WICHTIG: Nutzt das Python aus der venv, damit alle Libs gefunden werden!
ExecStart=/usr/share/pyarc-venv/bin/python3 /usr/local/bin/pyarc-milter
Restart=on-failure
User=postfix

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable pyarc-milter

echo "=================================================="
echo "✔ Installation sauber und meckerfrei abgeschlossen!"
echo "=================================================="
