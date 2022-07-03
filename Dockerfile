FROM docker.io/library/archlinux:latest

# Update packages to latest version
RUN pacman -Syu --noconfirm

# Install essential packages
RUN pacman -Sy --noconfirm \
  base-devel \
  zsh \
  vim \
  git \
  git-crypt \
  git-lfs \
  openssh \
  podman \
  npm \
  python \
  python-pip \
  neovim \
  rustup \
  man-db \
  man-pages \
  gnupg \
  htop \
  starship \
  fortune-mod \
  fzf \
  python-pywal \
  grc \
  sshpass

# Allow password-less sudo in the container
RUN sed -i -e 's/ ALL$/ NOPASSWD:ALL/' /etc/sudoers

# Fix an issue where tab completion added duplicate characters
# See https://stackoverflow.com/a/20953792
RUN sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

# Use build args to mirror the host user
ARG USER_ID
ARG GROUP_ID
ARG USER_NAME
ENV USER_HOME="/home/${USER_NAME}"
RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" && \
  useradd -l -u "${USER_ID}" -g "${USER_NAME}" -d "${USER_HOME}" "${USER_NAME}" && \
  install -d -m 0755 -o "${USER_NAME}" -g "${USER_NAME}" "${USER_HOME}"
USER "${USER_NAME}"
ENV HOME=${USER_HOME}
WORKDIR ${HOME}
ENV USER=${USER_NAME}
ENV LOCAL_BIN=${HOME}/.local/bin
RUN mkdir -p ${LOCAL_BIN}

# Set up rust
RUN rustup toolchain install stable
RUN rustup default stable
ENV PATH=${HOME}/.cargo/bin:${PATH}

# Install rust tools
RUN cargo install \
  lsd \
  fd-find \
  ripgrep \
  vivid \
  bat \
  navi
# didyoumean

# Install pythontools
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install \
  pyyaml \
  xxh \
  commitizen

# Install zsh package manager, antibody
RUN curl -sfL git.io/antibody | sh -s - -b ${LOCAL_BIN}

ENV PATH="${HOME}/.local/bin:${PATH}"

# Install lunar vim
ENV NPM_CONFIG_PREFIX=${HOME}/.npm-global
RUN mkdir ${NPM_CONFIG_PREFIX}
RUN curl --silent --output ./install-lvim.sh https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh
RUN chmod +x ./install-lvim.sh
RUN bash -c ./install-lvim.sh --yes
RUN rm ./install-lvim.sh

