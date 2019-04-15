#!/bin/sh
echo "Killing ROS"
kill -INT `cat /tmp/launch.pid`
