#!/bin/bash

# Step 1: Add the public key for Raspberry Pi repositories
echo "Adding public key for Raspberry Pi repositories..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E

# Step 2: Update the package list
echo "Updating package list..."
sudo apt update

# Step 3: Install tzdata if not already installed
if ! dpkg -l | grep -q tzdata; then
    echo "Installing tzdata..."
    sudo apt install tzdata -y
    if [ $? -ne 0 ]; then
        echo "Failed to install tzdata. Please check your repositories and try again."
        exit 1
    fi
else
    echo "tzdata is already installed."
fi

# Step 4: Set the timezone
echo "Setting timezone to Asia/Tehran..."
sudo timedatectl set-timezone Asia/Tehran
if [ $? -eq 0 ]; then
    echo "Timezone set to Asia/Tehran successfully."
else
    echo "Failed to set timezone. Make sure tzdata is installed and try again."
    exit 1
fi

# Step 5: Ensure systemd-timesyncd is enabled and running
echo "Enabling and starting systemd-timesyncd..."
sudo systemctl enable systemd-timesyncd
sudo systemctl start systemd-timesyncd
if [ $? -eq 0 ]; then
    echo "systemd-timesyncd is enabled and running. System time should be synchronized with NTP."
else
    echo "Failed to start systemd-timesyncd. Please check your internet connection."
    exit 1
fi

# Step 6: Verify the settings
echo "Current timezone: $(timedatectl show --property=Timezone --value)"
echo "Current time: $(date)"

# final versions
echo "installed: $(python${PYTHON_VERSION%.*} --version)"

