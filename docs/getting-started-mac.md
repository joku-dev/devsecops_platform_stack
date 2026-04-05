# Getting Started on macOS

Diese Anleitung beschreibt die **Erstinbetriebnahme auf dem Mac**, nachdem das Repository bereits in GitHub liegt.

## Ziel
Nach diesen Schritten hast du:

- das Repository lokal geklont
- die Dev-Umgebung gestartet
- VS Code im Dev Container geöffnet
- Security-, SBOM- und GitOps-Checks lokal ausgeführt
- deinen ersten Branch, Commit und Pull Request vorbereitet

## Voraussetzungen auf dem Mac

### 1. Homebrew
Falls Homebrew noch nicht installiert ist, zuerst installieren.

### 2. Benötigte Tools installieren
```bash
brew install --cask docker
brew install --cask visual-studio-code
brew install make git
```

Danach **Docker Desktop starten** und warten, bis Docker läuft.

## Repository lokal klonen

### 3. Repository klonen
```bash
git clone https://github.com/DEIN-ACCOUNT/DEIN-REPO.git
cd DEIN-REPO
```

Beispiel:
```bash
git clone https://github.com/joern/devsecops-stack.git
cd devsecops-stack
```

### 4. Repository-Struktur prüfen
```bash
ls
```

Erwartet werden unter anderem:
- `Makefile`
- `docker/`
- `ansible/`
- `k8s/`
- `terraform/`
- `.github/`
- `.devcontainer/`

## Lokale Konfiguration vorbereiten

### 5. `.env` erzeugen
```bash
cp docker/.env.example docker/.env
```

### 6. `.gitignore` prüfen
Stelle sicher, dass lokale Dateien nicht committed werden.

```bash
grep -qxF 'docker/.env' .gitignore || echo 'docker/.env' >> .gitignore
grep -qxF 'artifacts/' .gitignore || echo 'artifacts/' >> .gitignore
```

## Lokale Dev-Umgebung starten

### 7. Basis-Container starten
```bash
make up-local
```

Das startet:
- Workspace
- PostgreSQL
- Redis

### 8. Laufende Container prüfen
```bash
make ps-local
```

### 9. In den Workspace-Container wechseln
```bash
make shell-local
```

Dort kannst du testen:

```bash
terraform version
kubectl version --client
helm version
trivy --version
syft version
grype version
checkov --version
```

Mit `exit` verlässt du den Container wieder.

## VS Code im Dev Container nutzen

### 10. Repository in VS Code öffnen
```bash
code .
```

### 11. Dev Container starten
In VS Code:

1. `Cmd + Shift + P`
2. `Dev Containers: Reopen in Container`

Danach arbeitest du direkt im Linux-Container mit der vordefinierten Toolchain.

### 12. Prüfen, ob du im Container bist
Im VS-Code-Terminal:
```bash
whoami
```

Erwartete Ausgabe:
```bash
devuser
```

## Lokale DevSecOps-Checks ausführen

### 13. Linting ausführen
```bash
make lint
```

### 14. Policy-Checks ausführen
```bash
make policy
```

### 15. Checkov ausführen
```bash
make checkov
```

### 16. Security-Scan ausführen
```bash
make security
```

### 17. Secret-Scan ausführen
```bash
make secrets
```

### 18. SBOM erzeugen
CycloneDX:
```bash
make sbom-fs
```

SPDX:
```bash
make sbom-fs-spdx
```

### 19. SBOM scannen
```bash
make scan-sbom
```

### 20. Gesamten lokalen Qualitätslauf ausführen
```bash
make full-scan
```

Ergebnisse liegen unter:
```bash
artifacts/sbom/
```

## GitOps und Kubernetes lokal testen

### 21. GitOps-Struktur validieren
```bash
make gitops-validate
```

### 22. Optional: lokalen k3d-Cluster erzeugen
```bash
make k3d-create
make k3d-kubeconfig
kubectl get nodes
```

### 23. Beispiel-App rendern oder anwenden
Rendern:
```bash
kubectl kustomize k8s/apps/sample-app
```

Anwenden:
```bash
kubectl apply -k k8s/apps/sample-app
```

## Optionale Plattform-Services lokal starten

### 24. Plattform-Services
```bash
make up-platform
```

Erwartet:
- MinIO API auf `http://localhost:9000`
- MinIO Console auf `http://localhost:9001`
- Mailhog auf `http://localhost:8025`

### 25. Observability-Stack
```bash
make up-observability
```

Erwartet:
- Grafana auf `http://localhost:3000`

Die Zugangsdaten stehen in `docker/.env`.

## Erster Branch und erster Pull Request

### 26. Feature-Branch anlegen
```bash
git checkout -b feature/initial-test
```

### 27. Kleine Teständerung machen
Beispiel:
`k8s/apps/sample-app/deployment.yaml`

Ändere:
```yaml
replicas: 2
```

### 28. Vor dem Commit lokal validieren
```bash
make full-scan
make gitops-validate
```

### 29. Commit und Push
```bash
git add .
git commit -m "feat: scale sample app to 2 replicas"
git push origin feature/initial-test
```

### 30. Pull Request erstellen
In GitHub:
- Pull Request öffnen
- Checks abwarten:
  - Validate Infrastructure
  - Security and SBOM
  - GitOps Validate
  - optional Build Sign and Scan Container

## Alltagsempfehlung

Typischer täglicher Ablauf:

```bash
git checkout -b feature/xyz
make up-local
code .
```

Dann in VS Code:
- `Dev Containers: Reopen in Container`

Vor jedem Push:
```bash
make full-scan
make gitops-validate
```

Danach:
```bash
git add .
git commit -m "feat: xyz"
git push
```

## Aufräumen

### Container stoppen
```bash
make down-local
```

### k3d-Cluster löschen
```bash
make k3d-delete
```


## Python im Stack nutzen

### Beispielprojekt installieren
```bash
cd examples/python-app
poetry install
```

### Tests ausführen
```bash
make python-test
```

### Linting und Audit
```bash
make python-lint
make python-audit
```
