#!/bin/sh
bash ${HOME_DIR}/src/kill_ROS.sh

cd ${HOME_DIR}/iris-riot
echo "Checking out iris-riot branch"
git checkout ${RIOT_BRANCH}
git fetch origin
git reset --hard origin/${RIOT_BRANCH}

cd ../iris-ROS
echo "Checking out iris-ROS branch"
git checkout ${IRISBOT_BRANCH}
git fetch origin
git reset --hard origin/${IRISBOT_BRANCH}
echo "Building irisbot"
rm -rf build
catkin_make
cd ../

if [ "${FLASH_OPENMOTE}" = "t" ]; then
	echo "Flashing openmote"
	sh ${HOME_DIR}/src/flash.sh
fi

bash ${HOME_DIR}/src/launch_ROS.sh
