#!/bin/sh
bash kill_ROS.sh

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

if [ "${FLASH_OPENMOTE}" = "t" ]; then
	sh ${HOME_DIR}/src/flash.sh
fi

bash launch_ROS.sh
