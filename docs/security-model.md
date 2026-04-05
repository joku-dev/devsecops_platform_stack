# Security Model

## Eingebaute Kontrollen

- Trivy für Vulnerabilities, Secrets und Misconfiguration
- Syft für SBOM-Erzeugung
- Grype für SBOM- und Package-Scans
- Checkov für IaC-Checks
- TruffleHog für Secret Detection
- Conftest / OPA für Policies
- Cosign für Signierung

## Wichtige Annahmen

- Docker-Socket-Zugriff ist in lokalen Dev-Setups bewusst erlaubt
- `.env` ist nur für Entwicklung gedacht
- produktive Secrets müssen in echte Secret-Backends ausgelagert werden
