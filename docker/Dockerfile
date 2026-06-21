FROM debian:12

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000
ARG TERRAFORM_VERSION=1.14.8
ARG HELM_VERSION=4.1.3
ARG KUBECTL_VERSION=v1.35.3
ARG K3D_VERSION=v5.7.2
ARG TFLINT_VERSION=v0.60.0
ARG TRIVY_VERSION=0.69.3
ARG SYFT_VERSION=v1.42.3
ARG GRYPE_VERSION=v0.110.0
ARG COSIGN_VERSION=v3.0.2
ARG TRUFFLEHOG_VERSION=v3.94.2
ARG HADOLINT_VERSION=v2.10.0
ARG OPA_VERSION=v1.13.2
ARG CONFTEST_VERSION=v0.59.0

ENV DEBIAN_FRONTEND=noninteractive
ENV POETRY_HOME=/opt/poetry
ENV PATH="${POETRY_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    docker.io \
    gh \
    git \
    gnupg \
    htop \
    jq \
    lsb-release \
    nano \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    libffi-dev \
    libssl-dev \
    shellcheck \
    software-properties-common \
    tar \
    unzip \
    vim \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm /tmp/terraform.zip

RUN curl -fsSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN wget -O /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

RUN wget -O /usr/local/bin/k3d https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-amd64 \
    && chmod +x /usr/local/bin/k3d

RUN wget -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip /tmp/tflint.zip -d /usr/local/bin \
    && rm /tmp/tflint.zip

RUN wget -O /tmp/trivy.deb https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb \
    && apt-get update \
    && apt-get install -y /tmp/trivy.deb \
    && rm /tmp/trivy.deb \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/syft.tar.gz https://github.com/anchore/syft/releases/download/${SYFT_VERSION}/syft_$(echo ${SYFT_VERSION} | sed 's/^v//')_linux_amd64.tar.gz \
    && tar -xzf /tmp/syft.tar.gz -C /tmp \
    && mv /tmp/syft /usr/local/bin/syft \
    && chmod +x /usr/local/bin/syft \
    && rm -rf /tmp/syft /tmp/syft.tar.gz /tmp/CHANGELOG.md /tmp/LICENSE /tmp/README.md

RUN wget -O /tmp/grype.tar.gz https://github.com/anchore/grype/releases/download/${GRYPE_VERSION}/grype_$(echo ${GRYPE_VERSION} | sed 's/^v//')_linux_amd64.tar.gz \
    && tar -xzf /tmp/grype.tar.gz -C /tmp \
    && mv /tmp/grype /usr/local/bin/grype \
    && chmod +x /usr/local/bin/grype \
    && rm -rf /tmp/grype /tmp/grype.tar.gz /tmp/CHANGELOG.md /tmp/LICENSE /tmp/README.md

RUN wget -O /usr/local/bin/cosign https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 \
    && chmod +x /usr/local/bin/cosign

RUN wget -O /tmp/trufflehog.tar.gz https://github.com/trufflesecurity/trufflehog/releases/download/${TRUFFLEHOG_VERSION}/trufflehog_$(echo ${TRUFFLEHOG_VERSION} | sed 's/^v//')_linux_amd64.tar.gz \
    && tar -xzf /tmp/trufflehog.tar.gz -C /tmp \
    && mv /tmp/trufflehog /usr/local/bin/trufflehog \
    && chmod +x /usr/local/bin/trufflehog \
    && rm -rf /tmp/trufflehog /tmp/trufflehog.tar.gz

RUN wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 \
    && chmod +x /usr/local/bin/hadolint

RUN wget -O /usr/local/bin/opa https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_amd64_static \
    && chmod +x /usr/local/bin/opa

RUN wget -O /tmp/conftest.tar.gz https://github.com/open-policy-agent/conftest/releases/download/v0.59.0/conftest_0.59.0_Linux_x86_64.tar.gz \
    && tar -xzf /tmp/conftest.tar.gz -C /tmp \
    && mv /tmp/conftest /usr/local/bin/conftest \
    && chmod +x /usr/local/bin/conftest \
    && rm -rf /tmp/conftest /tmp/conftest.tar.gz


RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip setuptools wheel \
    && pip3 install --break-system-packages --no-cache-dir \
    ansible \
    ansible-lint \
    yamllint \
    pre-commit \
    checkov \
    poetry \
    ruff \
    black \
    pytest \
    mypy \
    pip-audit

RUN npm install -g yarn pnpm

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

USER ${USERNAME}
WORKDIR /workspace

CMD ["sleep", "infinity"]
