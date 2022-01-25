FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.9-bullseye

# Prepare for Go
ENV GOROOT=/usr/local/go \
    GOPATH=/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}
ENV DOCKER_BUILDKIT=1
      
# Install gh docker-ce docker-ce-cli containerd.io kubectl helm google-cloud-sdk
RUN bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/github-debian.sh")" \
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-debian.sh")" \
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/terraform-debian.sh")" \
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh")" \
  && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/go-debian.sh")" \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Node
RUN su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install "lts/*" 2>&1"

RUN mkdir /workplace && chown vscode /workplace

# Install poetry
USER vscode
RUN curl -sSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py \
  | python -

# Install 1Password
RUN mkdir /home/vscode/scripts \
  && curl -sL https://cache.agilebits.com/dist/1P/op/pkg/v1.12.3/op_linux_arm64_v1.12.3.zip -o /home/vscode/op.zip \
  && unzip -j /home/vscode/op.zip "op" -d "/home/vscode/scripts"
# Set profile values
RUN echo "source /home/vscode/1penv.sh" >> /home/vscode/.bashrc \
  && echo 'export PATH=$HOME/.poetry/bin:$PATH' >> /home/vscode/.bashrc \
  && echo 'export PATH=$PATH:$HOME/scripts' >> /home/vscode/.bashrc \
  && echo "export ENVINJ_SKIP=\"export 1penv\"" >> /home/vscode/.bashrc \
  && echo "export ENVINJ_APPS=\"uvicorn alembic\"" >> /home/vscode/.bashrc \
  && echo 'export ENVINJ_PROVIDER='\''1penv $app api enableops'\' >> /home/vscode/.bashrc \
  && echo "source /home/vscode/env-injector/activate.sh" >> /home/vscode/.bashrc \
  && echo 'export POETRY_CACHE_DIR=/workspace/poetry' >> /home/vscode/.bashrc

# 1Password config
RUN mkdir -p /home/vscode/.config/op && chmod 700 /home/vscode/.config/op && echo "hello" > /home/vscode/.config/op/config

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ENTRYPOINT ["/usr/local/share/docker-init.sh"]
