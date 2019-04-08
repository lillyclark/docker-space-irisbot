FROM ros:kinetic-ros-base-xenial

WORKDIR /home/lilly/Desktop/DockerSpace

COPY ./ .

RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-base=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install python-setuptools
RUN easy_install pip
RUN pip install RPi.GPIO serial

#CMD ./container_boot.sh
