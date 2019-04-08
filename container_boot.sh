#!/bin/sh
cd irisbot_ROS
rm -rf build
catkin_make
cd ../
bash launch_ROS.sh
