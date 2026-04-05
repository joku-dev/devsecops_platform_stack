# Architecture

Die Plattform trennt vier Ebenen:

1. **Host Layer**
   - Debian-Server
   - Provisionierung über Ansible

2. **Runtime Layer**
   - Docker Compose lokal/remote
   - Workspace, Datenbanken, Plattform-Services

3. **Platform Layer**
   - Kubernetes Manifeste
   - GitOps mit Argo CD
   - External Secrets
   - Observability

4. **Security & Supply Chain Layer**
   - SBOM
   - Scans
   - Policies
   - Signierung
