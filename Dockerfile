# Create an image suited to building Yocto images using the source code
#  provided in the src/ directory and configuration files.

# Because volumes aren't first-class citizens in Dockerfiles,
#  n.b. that the build script expects a host mount at
#   /usr/local/share/yocto/
# For example,
#  docker run --rm -ti -v $(readlink -f ./output):/usr/local/share/yocto yocto/cubox:latest /sbin/my_init -- bash -l

FROM yoctoprep-env
MAINTAINER Brandon Matthews <bmatt@luciddg.com>

# Pro-forma phusion/baseimage support
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

WORKDIR /usr/local/src/yocto/

RUN git clone -b dizzy          http://git.yoctoproject.org/git/poky
RUN git clone -b read-only-root https://github.com/luciddg/meta-web-kiosk
RUN git clone -b dizzy          http://git.yoctoproject.org/git/meta-fsl-arm
RUN git clone -b dizzy          https://github.com/Freescale/meta-fsl-arm-extra
RUN git clone                   https://github.com/luciddg/meta-luciddg-kiosk.git

# Copy relevant configuration files
ADD build/ /usr/local/src/yocto/build/

# Put the build wrapper script in place
ADD build-yocto.sh /usr/local/src/yocto/

# Clean up APT when done.
USER root
# Workaround Docker bug #7537
RUN chown -R yocto:yocto /usr/local/src/yocto/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
