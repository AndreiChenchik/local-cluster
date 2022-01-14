ARG VARIANT=3-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends curl make gcc

USER vscode
RUN curl -sSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py \
  | python -

RUN mkdir /home/vscode/scripts \
  && curl -sL https://cache.agilebits.com/dist/1P/op/pkg/v1.12.3/op_linux_arm64_v1.12.3.zip -o /home/vscode/op.zip \
  && unzip -j /home/vscode/op.zip "op" -d "/home/vscode/scripts"
RUN echo "source /home/vscode/1penv.sh" >> /home/vscode/.bashrc \
  && echo 'export PATH=$HOME/.poetry/bin:$PATH' >> /home/vscode/.bashrc \
  && echo 'export PATH=$PATH:$HOME/scripts' >> /home/vscode/.bashrc \
  && echo "export ENVINJ_SKIP=\"env python\"" >> /home/vscode/.bashrc \
  && echo "export ENVINJ_APPS=\"uvicorn\"" >> /home/vscode/.bashrc \
  && echo 'export ENVINJ_PROVIDER='\''1penv $1'\' >> /home/vscode/.bashrc \
  && echo "source /home/vscode/env-injector/activate.sh" >> /home/vscode/.bashrc

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
