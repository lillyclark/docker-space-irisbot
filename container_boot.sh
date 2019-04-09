#!/bin/bash

echo "flashing openmote"
if [ "${FLASH_OPENMOTE}" = "t" ]; then
	.${HOME_DIR}/src/flash.sh
fi

echo "Building irisbot"
cd irisbot_ROS
rm -rf build
catkin_make
cd ../
bash launch_ROS.sh

echo "Starting core"
python3 ${HOME_DIR}/irisbot-python/core.py
