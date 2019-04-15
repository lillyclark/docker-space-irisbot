#!/bin/sh
if bash ${HOME_DIR}/src/kill_ROS.sh; then
    sleep 2
    . ${HOME_DIR}/iris-ROS/devel/setup.bash
    echo "Launching irisbot.launch"
    roslaunch --pid=/tmp/launch.pid irisbot irisbot.launch role:=${APP_PARAMS}
else
    . ${HOME_DIR}/iris-ROS/devel/setup.bash
    echo "Launching irisbot.launch"
    roslaunch --pid=/tmp/launch.pid irisbot irisbot.launch role:=${APP_PARAMS}
fi
