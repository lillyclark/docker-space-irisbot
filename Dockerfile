# docker build -t irisbot_ros .
# docker run -it --rm --name bot irisbot_ros

FROM jbrisbin/rpi-python3
USER root
WORKDIR /usr/src

RUN apt-get update
RUN apt-get install python python-serial git build-essential gcc-arm-none-eabi libnewlib-arm-none-eabi wget unzip
RUN apt-get install rpi.gpio python3-serial
RUN pip3 install httpserver numpy
RUN git config --global user.name "anrggithub-official"
RUN git config --global user.email "code@anrg.usc.edu"

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-core=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

ARG riot_app=hello-world
ARG irisbot_app=helloworld
ARG app_params=None
ARG riot_branch=master
ARG irisbot_branch=master
ARG flash_openmote=f
ARG target=native

ENV RIOT_APP $riot_app
ENV RIOT_BRANCH $riot_branch
ENV IRISBOT_APP $irisbot_app
ENV IRISBOT_BRANCH $irisbot_branch
ENV FLASH_OPENMOTE $flash_openmote
ENV APP_PARAMS $app_params
ENV HOME_DIR /usr/src
ENV TARGET $target

EXPOSE 8080

COPY . .

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
