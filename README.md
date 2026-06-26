# DevSecOps Stack

Reproduzierbare Development-, Platform- und DevSecOps-Umgebung für **macOS**, **Debian-Server**, **RHEL-kompatible Systeme** und **GitHub**.

Diese Version erweitert den Stack gezielt um **Python-Unterstützung** für Entwicklung, Qualitätssicherung und Security.

## Enthaltene Bereiche

### Development
- VS Code Dev Container
- Debian-basierter Workspace
- GitHub CLI (`gh`) und VS-Code Pull-Request-Integration
- PostgreSQL, Redis
- optionale Plattform-Services: MinIO, Mailhog

### DevOps
- Terraform
- kubectl
- Helm
- k3d
- Ansible
- TFLint

### DevSecOps
- Trivy
- Syft
- Grype
- Checkov
- TruffleHog
- Hadolint
- ShellCheck
- Conftest / OPA
- Cosign
- pre-commit

### Python
- Python 3
- `venv`
- Poetry
- Ruff
- Black
- Pytest
- MyPy
- pip-audit
- Beispielprojekt unter `examples/python-app/`

## Wichtige Dateien

- `docker/Dockerfile`
- `docker/compose.local.yml`
- `docker/compose.remote.yml`
- `.devcontainer/devcontainer.json`
- `Makefile`
- `docs/getting-started-mac.md`
- `docs/deployment-debian.md`
- `docs/deployment-rhel.md`
- `docs/python.md`

## Gemeinsamer Workspace

Der lokale Dev Container mountet einen Host-Ordner mit mehreren Repositories nach
`/workspace`. Kopiere `docker/.env.example` nach `docker/.env` und setze
`WORKSPACE_ROOT` auf den absoluten Pfad dieses Host-Ordners:

```text
~/Development/
├── devsecops_platform_stack/
└── ai-native-engineering-factory/
```

Nach **Dev Containers: Rebuild and Reopen in Container** liegen die Repositories
im Container unter `/workspace/devsecops_platform_stack` und
`/workspace/ai-native-engineering-factory`. Der Stack wird automatisch im ersten
Pfad geöffnet. Bestehende Clones im alten Workspace-Mount müssen vor dem Rebuild
in den gemeinsamen Host-Ordner verschoben werden.

## Python-Workflow

### Beispielprojekt installieren
```bash
cd examples/python-app
poetry install
```

### Tests ausführen
```bash
make python-test
```

### Linting / Typprüfung
```bash
make python-lint
```

### Dependency Audit
```bash
make python-audit
```

## GitHub-Workflow Im Dev Container

Nach dem ersten Start des Dev Containers einmal interaktiv anmelden:

```bash
gh auth login
gh auth status
```

Die Authentifizierung bleibt im persistierten Home-Volume des Workspace-Containers. Zugangstokens dürfen nicht in `docker/.env`, Compose-Dateien oder das Repository geschrieben werden.

## Git-Commit-Signaturen

Der Stack unterstützt SSH-basierte Git-Signaturen. Sie sind für GitHub geeignet und nutzen den weitergereichten SSH-Agent, ohne private Schlüssel im Image abzulegen.

```bash
make git-signing-setup SIGNING_KEY=~/.ssh/id_ed25519_signing.pub
make git-signing-check
```

Die vollständige Einrichtung einschließlich GitHub-Key-Upload und lokaler Verifikation steht in `docs/factory-development-stack.md`.

## Schritt-für-Schritt-Anleitungen

- `docs/getting-started-mac.md` → Erstinbetriebnahme auf dem Mac
- `docs/deployment-debian.md` → Deployment auf Debian-Server
- `docs/deployment-rhel.md` → Deployment auf RHEL / Rocky / AlmaLinux
- `docs/python.md` → Python-Nutzung im Stack
