# Deployment auf RHEL / Rocky Linux / AlmaLinux

Diese Anleitung beschreibt die **Erstinbetriebnahme auf einem RHEL-kompatiblen Server**, nachdem das Repository bereits in GitHub liegt.

Die aktualisierte Ansible-Provisionierung unterstützt jetzt sowohl:
- **Debian / Ubuntu-nahe Systeme**
- **RHEL / Rocky Linux / AlmaLinux**

## Ziel

Nach diesen Schritten hast du:

- einen RHEL-kompatiblen Server per Ansible provisioniert
- Docker und Docker Compose Plugin auf dem Host eingerichtet
- `firewalld` für Basisfreigaben vorbereitet
- das Repository auf den Server gebracht
- die Remote-Dev-Umgebung gestartet

## Unterstützte Zielsysteme

Empfohlen:
- **RHEL 9**
- **Rocky Linux 9**
- **AlmaLinux 9**

Die Anleitung ist vor allem auf **RHEL-kompatible Systeme mit `dnf`** ausgelegt.

## Voraussetzungen auf deinem Mac

```bash
brew install git ansible
```

Zusätzlich brauchst du:
- SSH-Zugriff auf den Zielserver
- einen Benutzer mit `sudo` oder `root`
- Zugriff auf dein GitHub-Repository

## Schritt 1: Repository lokal klonen

```bash
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git
cd DEIN-REPO
```

## Schritt 2: Inventory anpassen

Datei:
`ansible/inventory.ini`

Beispiel mit Root:
```ini
[dev]
rhel-dev ansible_host=DEINE_SERVER_IP ansible_user=root
```

Beispiel mit Admin-User:
```ini
[dev]
rhel-dev ansible_host=DEINE_SERVER_IP ansible_user=deinuser
```

## Schritt 3: Optional SSH-Key für den Dev-User setzen

Datei:
`ansible/group_vars/all.yml`

```yaml
dev_user_authorized_keys:
  - "ssh-ed25519 AAAA... dein-key"
```

## Schritt 4: Optionale Portfreigaben für firewalld setzen

Falls du auf dem Host zusätzliche TCP-Ports brauchst, trage sie in `ansible/group_vars/all.yml` ein:

```yaml
firewalld_allowed_tcp_ports:
  - "3000"
  - "8025"
  - "9001"
```

## Schritt 5: Ansible Collections installieren

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Schritt 6: Verbindung testen

```bash
make ping
```

## Schritt 7: RHEL-Host provisionieren

```bash
make provision
```

Das Playbook richtet auf RHEL-kompatiblen Hosts typischerweise ein:
- Basis-Pakete via `dnf`
- Docker CE Repository
- Docker Engine + Compose Plugin
- Dev-User mit Gruppe `wheel`
- `firewalld`
- Projektverzeichnis unter `/opt/dev-environment`

## Schritt 8: Auf den Server einloggen

```bash
ssh root@DEINE_SERVER_IP
```

oder mit deinem Admin-User.

## Schritt 9: Repository auf dem Server klonen

```bash
cd /opt
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git dev-environment
cd /opt/dev-environment
```

## Schritt 10: `.env` erzeugen

```bash
cp docker/.env.example docker/.env
```

Optional bearbeiten:

```bash
vi docker/.env
```

Für öffentlich erreichbare Hosts solltest du die Default-Passwörter anpassen.

## Schritt 11: Remote-Container starten

```bash
make up-remote
```

## Schritt 12: Container prüfen

```bash
make ps-remote
```

Erwartet:
- `dev-workspace-remote`
- `dev-postgres-remote`
- `dev-redis-remote`

## Schritt 13: In den Workspace-Container wechseln

```bash
make shell-remote
```

Dort kannst du z. B. testen:

```bash
terraform version
kubectl version --client
helm version
trivy --version
syft version
grype version
```

## Schritt 14: Optionale Plattform-Services starten

```bash
docker compose -f docker/compose.remote.yml --env-file docker/.env --profile platform up -d
```

## Schritt 15: Optionale Observability starten

```bash
docker compose -f docker/compose.remote.yml --env-file docker/.env --profile observability up -d
```

## Schritt 16: Betrieb und Updates

Für Updates:

```bash
cd /opt/dev-environment
git pull
make up-remote
```

## Hinweise zu RHEL

- Auf **RHEL-kompatiblen Systemen** wird `firewalld` statt `ufw` verwendet.
- Der Dev-User wird der Gruppe **`wheel`** hinzugefügt, nicht `sudo`.
- Das Docker-Repository wird aus der **Docker CE CentOS Repo-Datei** eingebunden, was für Rocky/Alma/RHEL-kompatible Setups üblich ist.
- SELinux kann je nach Härtung und Volume-Mounts zusätzliche Anpassungen erfordern. Für einen späteren Ausbau kann man Compose-Volumes mit passenden SELinux-Kontexten oder dedizierten Policies ergänzen.

## Empfohlener Ablauf

1. lokal auf dem Mac ändern
2. lokal testen:
   ```bash
   make full-scan
   make gitops-validate
   ```
3. Änderungen nach GitHub pushen
4. Pull Request mergen
5. auf dem RHEL-Server:
   ```bash
   cd /opt/dev-environment
   git pull
   make up-remote
   ```
