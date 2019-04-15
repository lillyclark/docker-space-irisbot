#!/bin/sh
usage ()
{
  echo 'Usage : ./build.sh -tar <target> -ib <irisbot branch> -ia <irisbot app> -tag <tag name> [-p app_params] [-f <flash on boot (t/f)> -rb <riot branch> -ra <riot app>] [test]'
  exit
}

if [ "$#" -ne 13 ] && [ "$#" -ne 7 ] && [ "$#" -ne 14 ] && [ "$#" -ne 8 ] && [ "$#" -ne 15 ] && [ "$#" -ne 9 ] && [ "$#" -ne 16 ] && [ "$#" -ne 10 ]; then
  usage
fi


FLASH="f"
TEST=false
APP_PARAMS="not anchor"
GIT_TOKEN=c2e036ef563ba2701d671809e3a6d00fa870d296

while [ "$1" != "" ]; do
case $1 in
		-tar )         shift
                       TARGET=$1
                       ;;
        -rb )           shift
                       RIOT_BRANCH=$1
                       ;;
        -ra ) 			shift
                       RIOT_APP=$1
                       ;;
        -ib )           shift
                       IRISBOT_BRANCH=$1
                       ;;
        -ia )           shift
                       IRISBOT_APP=$1
                       ;;
        -f )           shift
                       FLASH=$1
                       ;;
        -tag )         shift
                       TAG=$1
                       ;;
        -p )           shift
                       APP_PARAMS=$1
                       ;;
        test )         TEST=true
                       ;;
        * )            QUERY=$1
    esac
    shift
done

# extra validation
if [ "$TARGET" = "" ]; then
    usage
fi

if [ "$IRISBOT_BRANCH" = "" ]; then
    usage
fi

if [ "$IRISBOT_APP" = "" ]; then
    usage
fi

if [ "$TAG" = "" ]; then
    usage
fi

if [ "$FLASH" != "f" ] && [ "$FLASH" != "t" ]; then
    usage
fi

if [ "$FLASH" = "t" ]; then
	if [ "$RIOT_BRANCH" = "" ]; then
	    usage
	fi
	if [ "$RIOT_APP" = "" ]; then
	    usage
	fi
else
	RIOT_BRANCH="develop"
	RIOT_APP="hello-world"
fi

if [ ! -d "iris-riot" ]; then
	git clone https://$GIT_TOKEN@github.com/ANRGUSC/iris-riot.git
	cd iris-riot
else
	cd iris-riot
	git checkout $RIOT_BRANCH
	git fetch origin
	git reset --hard origin/$RIOT_BRANCH
fi

git checkout $RIOT_BRANCH
cd ..

if [ ! -d "iris-ROS" ]; then
	git clone https://$GIT_TOKEN@github.com/ANRGUSC/iris-ROS.git
	cd iris-ROS
else
	cd iris-ROS
	git checkout $IRISBOT_BRANCH
	git fetch origin
	git reset --hard origin/$IRISBOT_BRANCH
fi

git checkout $IRISBOT_BRANCH
cd ..

if [ "$TEST" = "false" ]; then
	if [ $(docker inspect -f {{.State.Running}} irisbot_container) ]; then
		docker stop irisbot_container
	fi

	docker build . -t irisbot_image:$TAG \
		--build-arg target=$TARGET \
		--build-arg riot_app=$RIOT_APP \
		--build-arg irisbot_app=$IRISBOT_APP \
		--build-arg riot_branch=$RIOT_BRANCH \
		--build-arg irisbot_branch=$IRISBOT_BRANCH \
		--build-arg flash_openmote=$FLASH \
		--build-arg app_params="$APP_PARAMS"

else
	export RIOT_APP=$RIOT_APP
	export IRISBOT_APP=$IRISBOT_APP
	export RIOT_BRANCH=$RIOT_BRANCH
	export IRISBOT_BRANCH=$IRISBOT_BRANCH
	export FLASH_OPENMOTE=$FLASH
	export HOME_DIR=$(pwd)
	export GIT_TOKEN=$GIT_TOKEN
	export IN_CONTAINER=false
	./container_boot.sh
fi
