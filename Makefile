ANSIBLE_INVENTORY=ansible/inventory.ini
ANSIBLE_PLAYBOOK=ansible/playbook.yml
LOCAL_COMPOSE=docker/compose.local.yml
REMOTE_COMPOSE=docker/compose.remote.yml
ENV_FILE=docker/.env
K3D_CLUSTER_NAME=dev-local
ARTIFACT_DIR=artifacts/sbom
WORKSPACE_LOCAL=dev-workspace-local
WORKSPACE_REMOTE=dev-workspace-remote
WORKSPACE_IMAGE_LOCAL=devsecops-stack-workspace
WORKSPACE_IMAGE_REMOTE=devsecops-stack-workspace

provision:
	ansible-playbook -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK)

ping:
	ansible -i $(ANSIBLE_INVENTORY) dev -m ping

up-local:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) up -d --build workspace postgres redis

up-platform:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) --profile platform up -d minio mailhog

up-observability:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) --profile observability up -d grafana loki promtail

down-local:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) down

logs-local:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) logs -f

ps-local:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) ps

shell-local:
	docker exec -it $(WORKSPACE_LOCAL) bash

up-remote:
	docker compose -f $(REMOTE_COMPOSE) --env-file $(ENV_FILE) up -d --build

down-remote:
	docker compose -f $(REMOTE_COMPOSE) --env-file $(ENV_FILE) down

logs-remote:
	docker compose -f $(REMOTE_COMPOSE) --env-file $(ENV_FILE) logs -f

ps-remote:
	docker compose -f $(REMOTE_COMPOSE) --env-file $(ENV_FILE) ps

shell-remote:
	docker exec -it $(WORKSPACE_REMOTE) bash

config-local:
	docker compose -f $(LOCAL_COMPOSE) --env-file $(ENV_FILE) config

config-remote:
	docker compose -f $(REMOTE_COMPOSE) --env-file $(ENV_FILE) config

syntax:
	ansible-playbook -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK) --syntax-check

lint:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "ansible-lint /workspace/ansible/playbook.yml && yamllint /workspace && hadolint /workspace/docker/Dockerfile && tflint --init && tflint /workspace || true"

policy:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "conftest test /workspace/k8s --policy /workspace/policies"

checkov:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "checkov -d /workspace --config-file /workspace/.checkov.yaml"

security:
	mkdir -p $(ARTIFACT_DIR)
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "trivy fs --scanners vuln,secret,misconfig /workspace | tee /workspace/$(ARTIFACT_DIR)/trivy-fs.txt"

security-image:
	mkdir -p $(ARTIFACT_DIR)
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "trivy image $(WORKSPACE_IMAGE_LOCAL) | tee /workspace/$(ARTIFACT_DIR)/trivy-image.txt"

secrets:
	mkdir -p $(ARTIFACT_DIR)
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "trufflehog filesystem /workspace --no-update --results=verified,unknown --json > /workspace/$(ARTIFACT_DIR)/trufflehog.json || true"

precommit:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace && pre-commit run --all-files"

sbom-dir:
	mkdir -p $(ARTIFACT_DIR)

sbom-fs: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "syft dir:/workspace -o cyclonedx-json=/workspace/$(ARTIFACT_DIR)/sbom-cyclonedx.json"

sbom-fs-spdx: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "syft dir:/workspace -o spdx-json=/workspace/$(ARTIFACT_DIR)/sbom-spdx.json"

sbom-image: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "syft $(WORKSPACE_IMAGE_LOCAL) -o cyclonedx-json=/workspace/$(ARTIFACT_DIR)/sbom-image-cyclonedx.json"

scan-sbom: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "grype sbom:/workspace/$(ARTIFACT_DIR)/sbom-cyclonedx.json | tee /workspace/$(ARTIFACT_DIR)/grype-sbom.txt"

grype-fs: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "grype dir:/workspace | tee /workspace/$(ARTIFACT_DIR)/grype-fs.txt"

grype-image: sbom-dir
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "grype $(WORKSPACE_IMAGE_LOCAL) | tee /workspace/$(ARTIFACT_DIR)/grype-image.txt"

cosign-generate-key:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace && cosign generate-key-pair"

gitops-validate:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "conftest test /workspace/k8s --policy /workspace/policies && kubectl kustomize /workspace/k8s/platform/argocd >/dev/null && kubectl kustomize /workspace/k8s/apps/sample-app >/dev/null"

k3d-create:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "k3d cluster create $(K3D_CLUSTER_NAME)"

k3d-delete:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "k3d cluster delete $(K3D_CLUSTER_NAME)"

k3d-kubeconfig:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "mkdir -p ~/.kube && k3d kubeconfig merge $(K3D_CLUSTER_NAME) --kubeconfig-merge-default --kubeconfig-switch-context"

full-scan: lint policy checkov security secrets sbom-fs scan-sbom


python-install:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace/examples/python-app && poetry install"

python-test:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace/examples/python-app && poetry run pytest"

python-lint:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace/examples/python-app && poetry run ruff check . && poetry run black --check . && poetry run mypy src"

python-format:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace/examples/python-app && poetry run ruff check --fix . && poetry run black ."

python-audit:
	docker exec -it $(WORKSPACE_LOCAL) bash -lc "cd /workspace/examples/python-app && poetry run pip-audit"

python-all: python-install python-lint python-test python-audit
