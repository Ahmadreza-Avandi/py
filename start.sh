#!/bin/bash

# Step 1: Backup the current sources.list file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Step 2: Set the standard sources.list for Raspberry Pi OS Bookworm
sudo bash -c 'echo "deb http://raspbian.raspberrypi.org/raspbian bookworm main contrib non-free rpi" > /etc/apt/sources.list'
sudo bash -c 'echo "deb http://archive.raspberrypi.org/debian bookworm main" >> /etc/apt/sources.list'

# Step 3: Remove any Docker repository files (if present) to avoid conflicts
sudo rm /etc/apt/sources.list.d/docker.list 2>/dev/null || true

# Step 4: Update apt to ensure repositories are correctly configured
sudo apt update

# Step 5: Upgrade all installed packages to their latest versions
sudo apt upgrade -y

# Step 6: Install necessary apt packages (Redis server and QtWayland)
sudo apt install -y redis-server qtwayland5

# Step 7: Start and enable Redis server to ensure it's running
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Step 8: Activate the virtual environment (assuming it's located in ~/Desktop/py/venv)
source ~/Desktop/py/venv/bin/activate

# Step 9: Upgrade pip to ensure you have the latest version
pip install --upgrade pip

# Step 10: Install the correct pip packages (OpenCV with contrib and Redis)
pip install opencv-contrib-python redis
