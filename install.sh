#!/usr/bin/env bash
set -e

# Sicherstellen, dass das Skript als root ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte als root ausführen (sudo ./install.sh)"
  exit 1
fi

echo "=== Installiere pyarc-milter ==="

# 1. System-Abhängigkeiten installieren
echo "--> Installiere System-Abhängigkeiten..."
if [ -f /etc/debian_version ]; then
    apt-get update && apt-get install -y libmilter-dev python3-dev build-essential python3-pip
elif [ -f /etc/redhat-release ]; then
    dnf install -y sendmail-devel python3-devel gcc python3-pip
fi

# 2. Python-Pakete installieren
echo "--> Installiere Python-Pakete..."
pip3 install pymilter dkimpy authres cryptography --break-system-packages || pip3 install pymilter dkimpy authres cryptography

# 3. Ordnerstrukturen anlegen
echo "--> Erstelle Verzeichnisse und setze Rechte..."
mkdir -p /etc/pyarc/certs
mkdir -p /var/log/pyarc

# 4. Dateien kopieren
echo "--> Kopiere Skripte und Konfiguration..."
cp usr/local/bin/my_arc_milter.py /usr/local/bin/
cp usr/local/bin/pyarc-gen /usr/local/bin/
chmod '+x' /usr/local/bin/my_arc_milter.py
chmod '+x' /usr/local/bin/pyarc-gen

# Nur kopieren, wenn noch keine Config existiert (Überschreibschutz)
if [ ! -f /etc/pyarc/milter.conf ]; then
    cp etc/pyarc/milter.conf.template /etc/pyarc/milter.conf
    echo "✔ Standard-Konfiguration unter /etc/pyarc/milter.conf angelegt."
else
    echo "ℹ /etc/pyarc/milter.conf existiert bereits. Übersprungen."
fi

# Rechte für Postfix anpassen
chown -R postfix:postfix /etc/pyarc
chown -R postfix:postfix /var/log/pyarc
chmod 750 /etc/pyarc
chmod 755 /var/log/pyarc

# 5. Systemd Service einrichten
echo "--> Erstelle Systemd-Service..."
cp pyarc-milter.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable pyarc-milter

echo "=================================================="
echo "✔ Installation abgeschlossen!"
echo "=================================================="
echo "Nächste Schritte:"
echo "1. Passe /etc/pyarc/milter.conf an (auth_serv_id & Domains)."
echo "2. Generiere Keys mit: sudo pyarc-gen deine-domain.de"
echo "3. Starte den Service: sudo systemctl start pyarc-milter"
echo "4. Binde den Milter in die Postfix main.cf ein:"
echo "   smtpd_milters = inet:127.0.0.1:8899"
echo "=================================================="
