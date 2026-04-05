# DevSecOps Stack – Python

Diese Version des Stacks enthält eine einsatzfähige Python-Toolchain im Workspace-Container.

## Enthaltene Python-Werkzeuge

- Python 3
- pip
- venv
- Poetry
- Ruff
- Black
- Pytest
- MyPy
- pip-audit

## Schnellstart

```bash
cd examples/python-app
poetry install
poetry run pytest
```

## Make-Targets

Aus dem Repo-Root:

```bash
make python-install
make python-test
make python-lint
make python-format
make python-audit
```

## Empfehlung

Für neue Python-Projekte im Stack:
- Dependencies mit Poetry verwalten
- Ruff + Black für Stil und Linting nutzen
- Pytest für Tests
- MyPy für Typprüfung
- pip-audit für Dependency-Security
