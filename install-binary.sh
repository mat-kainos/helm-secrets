#!/usr/bin/env bash
set -x
set -ueo pipefail

SOPS_VERSION="3.3.0"
SOPS_DEB_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb"
SOPS_LINUX_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux"

RED='\033[0;31m'
GREEN='\033[0;32m'
#BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NOC='\033[0m'

# Find some tools

HELM_DIR="$(dirname $(command -v helm))"


# Install the helm wrapper in the same dir as helm itself. That's not
# guaranteed to work, but it's better than hard-coding it.
HELM_WRAPPER="${HELM_DIR}/helm-wrapper"

if hash sops 2>/dev/null; then
    echo "sops is already installed:"
    sops --version
else

    # Try to install sops.

    ### Mozilla SOPS binary install
    if [ "$(uname)" == "Darwin" ];
    then
            brew install sops
    elif [ "$(uname)" == "Linux" ];
    then
        if which dpkg;
        then
            curl -sL "${SOPS_DEB_URL}" > /tmp/sops
            sudo dpkg -i /tmp/sops;

        else
            curl -sL "${SOPS_LINUX_URL}" > /tmp/sops
                chmod +x /tmp/sops
                mv /tmp/sops /usr/local/bin/
        fi
        rm /tmp/sops 2>/dev/null || true
    else
        echo -e "${RED}No SOPS package available${NOC}"
        exit 1
    fi
fi

### git diff config
if [ -x "$(command -v git --version)" ];
then
    git config --global diff.sopsdiffer.textconv "sops -d"
else
    echo -e "${RED}[FAIL]${NOC} Install git command"
    exit 1
fi
