# Deployment auf Debian-Server

Diese Anleitung beschreibt die **Erstinbetriebnahme auf einem Debian-Server**, nachdem das Repository bereits in GitHub liegt.

## Ziel
Nach diesen Schritten hast du:

- einen Debian-Server per Ansible provisioniert
- Docker und Basis-Tooling auf dem Host eingerichtet
- das Repository auf den Server gebracht
- die Remote-Dev-Umgebung gestartet
- Plattform- und Observability-Services optional aktiviert
- einen sauberen Betriebsablauf für Updates etabliert

## Voraussetzungen

### Lokale Voraussetzungen
Auf deinem Mac oder Administrationsrechner brauchst du:

```bash
brew install git ansible
```

Zusätzlich brauchst du:
- SSH-Zugriff auf den Debian-Server
- einen Benutzer mit `sudo` oder `root`
- Zugriff auf dein GitHub-Repository

### Zielsystem
Empfohlen:
- Debian 12
- öffentlicher oder interner SSH-Zugriff
- ausreichend RAM und CPU für Docker, Datenbanken und optionale Plattform-Services

## Schritt 1: Repository lokal klonen

```bash
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git
cd DEIN-REPO
```

## Schritt 2: Inventory anpassen

Datei:
`ansible/inventory.ini`

Beispiel:
```ini
[dev]
debian-dev ansible_host=DEINE_SERVER_IP ansible_user=root
```

Wenn du nicht als `root`, sondern mit einem Admin-User arbeitest:

```ini
[dev]
debian-dev ansible_host=DEINE_SERVER_IP ansible_user=deinuser
```

## Schritt 3: Optional SSH-Key für den Dev-User hinterlegen

Datei:
`ansible/group_vars/all.yml`

Beispiel:
```yaml
dev_user_authorized_keys:
  - "ssh-ed25519 AAAA... dein-key"
```

Damit kann der angelegte Dev-User später per SSH auf den Server zugreifen.

## Schritt 4: Ansible Collections installieren

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Schritt 5: Verbindung testen

```bash
make ping
```

Wenn das nicht funktioniert, zuerst SSH-Zugriff, Firewall und Benutzerrechte prüfen.

## Schritt 6: Host provisionieren

```bash
make provision
```

Das Playbook richtet typischerweise ein:
- Basis-Pakete
- Docker
- Docker Compose Plugin
- Dev-User
- Projektverzeichnis auf dem Server
- Basis-Firewall-Regeln

## Schritt 7: Repository auf den Server bringen

Es gibt zwei saubere Varianten.

### Variante A – direkt auf dem Server klonen
Per SSH auf den Server:

```bash
ssh root@DEINE_SERVER_IP
```

Dann auf dem Server:

```bash
cd /opt
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git dev-environment
cd /opt/dev-environment
```

### Variante B – per rsync kopieren
Vom Mac aus:

```bash
rsync -av --exclude '.git' ./ root@DEINE_SERVER_IP:/opt/dev-environment/
```

Für den ersten Start ist **Variante A** meist sauberer.

## Schritt 8: `.env` auf dem Server erzeugen

Auf dem Server im Repo-Verzeichnis:

```bash
cd /opt/dev-environment
cp docker/.env.example docker/.env
```

Optional bearbeiten:

```bash
nano docker/.env
```

Wichtige Werte:
- PostgreSQL
- MinIO
- Grafana

Für Entwicklung reichen die Default-Werte meist zunächst aus. Für öffentlich erreichbare Server solltest du Passwörter anpassen.

## Schritt 9: Remote-Container starten

Auf dem Server:

```bash
make up-remote
```

Damit startest du die Basisdienste:
- Workspace
- PostgreSQL
- Redis

## Schritt 10: Laufende Container prüfen

```bash
make ps-remote
```

Erwartet:
- `dev-workspace-remote`
- `dev-postgres-remote`
- `dev-redis-remote`

## Schritt 11: In den Workspace-Container gehen

```bash
make shell-remote
```

Dort kannst du prüfen:

```bash
terraform version
kubectl version --client
helm version
trivy --version
syft version
grype version
checkov --version
```

Mit `exit` verlässt du den Container.

## Schritt 12: Optional Plattform-Services auf dem Server starten

Für MinIO und Mailhog:

```bash
docker compose -f docker/compose.remote.yml --env-file docker/.env --profile platform up -d
```

Danach typischerweise erreichbar:
- MinIO API: Port 9000
- MinIO Console: Port 9001
- Mailhog UI: Port 8025

Achte darauf, nur benötigte Ports in deiner Firewall freizugeben.

## Schritt 13: Optional Observability auf dem Server starten

Für Grafana, Loki und Promtail:

```bash
docker compose -f docker/compose.remote.yml --env-file docker/.env --profile observability up -d
```

Danach typischerweise erreichbar:
- Grafana: Port 3000
- Loki: Port 3100

## Schritt 14: Remote-Validierung ausführen

Im Repo-Verzeichnis auf dem Server:

```bash
make config-remote
```

Optional zusätzlich im Workspace:

```bash
make shell-remote
```

Dann z. B.:

```bash
conftest test /workspace/k8s --policy /workspace/policies
syft dir:/workspace -o cyclonedx-json=/workspace/artifacts/sbom/server-sbom-cyclonedx.json
grype dir:/workspace
```

## Schritt 15: Updates aus GitHub einspielen

Wenn das Repository schon auf dem Server geklont ist:

```bash
cd /opt/dev-environment
git pull
make up-remote
```

Wenn sich Dockerfile oder Compose-Konfiguration geändert haben, baut `make up-remote` die Umgebung neu.

## Schritt 16: Sicherer Standard-Betriebsablauf

Empfohlener Ablauf bei Änderungen:

1. lokal auf dem Mac ändern
2. lokal testen:
   ```bash
   make full-scan
   make gitops-validate
   ```
3. Änderungen nach GitHub pushen
4. Pull Request mergen
5. auf dem Server:
   ```bash
   cd /opt/dev-environment
   git pull
   make up-remote
   ```

## Schritt 17: Remote-Logs prüfen

```bash
make logs-remote
```

Oder gezielt einzelne Container:

```bash
docker logs dev-workspace-remote
docker logs dev-postgres-remote
docker logs dev-redis-remote
```

## Schritt 18: Remote-Umgebung stoppen

```bash
make down-remote
```

## Schritt 19: Server-Härtung und Betriebshinweise

Für echten Dauerbetrieb solltest du zusätzlich umsetzen:

- nur benötigte Ports öffnen
- SSH absichern
- Passwörter in `docker/.env` ändern
- echte Secrets später in Secret-Backends auslagern
- Reverse Proxy für öffentlich erreichbare Dienste einsetzen
- Volumes und Backups für Postgres, MinIO und Grafana planen

## Typischer Remote-Alltag

### Erststart
```bash
make provision
ssh root@DEINE_SERVER_IP
cd /opt
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git dev-environment
cd /opt/dev-environment
cp docker/.env.example docker/.env
make up-remote
```

### Update
```bash
ssh root@DEINE_SERVER_IP
cd /opt/dev-environment
git pull
make up-remote
```

### Shutdown
```bash
ssh root@DEINE_SERVER_IP
cd /opt/dev-environment
make down-remote
```

## Empfehlung

Nutze den Debian-Server primär für:
- reproduzierbare Remote-Dev-Umgebung
- gemeinsame Integrationsumgebung
- zentrale Plattform-Services
- Testen von GitOps- und Container-Änderungen

Die eigentliche Entwicklung und die meisten Validierungen solltest du weiterhin lokal auf dem Mac und in GitHub Actions durchführen.
