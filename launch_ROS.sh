#!/bin/sh
if bash kill_ROS.sh; then
    sleep 2
    . irisbot_ROS/devel/setup.bash
    echo "Launching irisbot.launch"
    roslaunch --pid=/tmp/launch.pid irisbot irisbot.launch role:="anchor"
else
    . irisbot_ROS/devel/setup.bash
    echo "Launching irisbot.launch"
    roslaunch --pid=/tmp/launch.pid irisbot irisbot.launch role:="anchor"
fi
