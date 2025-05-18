#!/bin/bash

# Step 1: Enable camera interface
echo "Enabling camera interface..."
sudo raspi-config nonint do_camera 0

# Step 2: Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Step 3: Install additional dependencies for camera support
sudo apt install -y libatlas-base-dev libjasper-dev libqtgui4 libqt4-test

# Step 4: Reinstall OpenCV with camera support
source ~/Desktop/py/venv/bin/activate
pip uninstall -y opencv-contrib-python
pip install opencv-contrib-python

# Step 5: Test camera connection
echo "Testing camera connection..."
python3 -c "import cv2; cap = cv2.VideoCapture(0); print('Camera opened successfully' if cap.isOpened() else 'Camera failed to open')"

# Step 6: Deactivate the virtual environment
deactivate
