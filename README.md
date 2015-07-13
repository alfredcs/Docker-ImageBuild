This folder contains a Dockerfile template to build a desirable CentOS 7 image with reuiqred packages and configurations.

    %sudo docker build --rm -t local/c7-systemd .

To upgrade Docker to the latest release:
    wget -qO- https://get.docker.com/ | sh
