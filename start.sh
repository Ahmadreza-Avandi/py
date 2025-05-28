#!/bin/bash

set -e  # اگه یه جا خطا داد، اسکریپت متوقف شه

echo "🔁 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing required build tools for Python compilation..."
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

PYTHON_VERSION="3.12.3"

echo "⬇️ Downloading Python $PYTHON_VERSION..."
cd /tmp
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar -xf Python-$PYTHON_VERSION.tgz
cd Python-$PYTHON_VERSION

echo "⚙️ Configuring and building Python..."
./configure --enable-optimizations
make -j$(nproc)

echo "🚀 Installing Python $PYTHON_VERSION (altinstall)..."
sudo make altinstall

echo "🐍 Switching to new Python..."
PYTHON_BIN="python3.12"
$PYTHON_BIN --version

echo "📦 Installing Python dependencies..."
$PYTHON_BIN -m pip install --upgrade pip
$PYTHON_BIN -m pip install -r requirements.txt

echo "🚀 Starting the project: faceDetectionWithCamera.py"
$PYTHON_BIN faceDetectionWithCamera.py

