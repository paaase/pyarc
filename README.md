# pyarc-milter

Ein schlanker, multidomain-fähiger **ARC (Authenticated Received Chain) Milter** für Postfix, geschrieben in Python. Er validiert eingehende ARC-Signaturen und signiert ausgehende E-Mails dynamisch basierend auf der Absender-Domain.

## Features
- 🛡 **Eingehende ARC-Validierung:** Prüft ARC-Ketten und setzt `Authentication-Results` sowie `X-ARC: TRUE/FALSE`.
- 🔑 **Ausgehende ARC-Signierung:** Signiert Mails dynamisch basierend auf der From-Domain.
- 🌐 **Multidomain-fähig:** Unterschiedliche Schlüssel und Selektoren pro Domain über eine INI-Config steuerbar.
- 📝 **Eigenes Datei-Logging:** Schreibt übersichtliche Logs separat nach `/var/log/pyarc/pyarc.log`.
- ⚡ **Standalone Key-Generator:** Bringt das CLI-Tool `pyarc-gen` mit, um Keys zu erzeugen und fertige DNS-Records auszugeben.

## Installation

```bash
git clone https://git.bouquet24.de/paase/pyarc.git
cd pyarc
sudo ./install.sh

```

```bash
/etc/pyarc/milter.conf bearbeiten.


``` 


## PMG
```bash
 
cp /var/lib/pmg/templates/main.cf.in /etc/pmg/templates/main.cf.in

nano /etc/pmg/templates/main.cf.in


# Eigene Python-ARC-Milter Anbindung
smtpd_milters = inet:127.0.0.1:8899
non_smtpd_milters = inet:127.0.0.1:8899

# Wichtig: Was passiert, wenn der Milter mal abstürzt?
# 'accept' lässt Mails trotzdem durchgehen (empfohlen). 'reject' blockiert den Mailversand komplett.
milter_default_action = accept
