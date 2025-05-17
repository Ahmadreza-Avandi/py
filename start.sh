#!/bin/bash

# remove realvnc-vnc-server completely
sudo pkill -f vnc
sudo killall vncserver-x11 2>/dev/null || true
sudo killall vncserver-virtual 2>/dev/null || true
sudo killall vncserverui 2>/dev/null || true

sudo dpkg --remove --force-remove-reinstreq realvnc-vnc-server || true
sudo apt purge -y realvnc-vnc-server || true

# fix any broken installs
sudo dpkg --configure -a
sudo apt --fix-broken install -y

# update package list before installing build tools
sudo apt update

# install build dependencies for Python
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# set desired Python version
PYTHON_VERSION=3.12.3

# download and build Python from source
cd /usr/src
sudo wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
sudo tar xzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
sudo ./configure --enable-optimizations
sudo make -j$(nproc)
sudo make altinstall

# ensure pip for new Python
sudo /usr/local/bin/python${PYTHON_VERSION%.*} -m ensurepip

# set new python3 as alternative
sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python${PYTHON_VERSION%.*} 1

# final versions
echo "installed: $(python${PYTHON_VERSION%.*} --version)"

