
FROM phusion/baseimage
MAINTAINER Brandon Matthews <bmatt@optimaltour.us>

# Pro-forma phusion/baseimage support
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Add necessary packages for building and generating documentation
#  (from http://www.yoctoproject.org/docs/current/yocto-project-qs/yocto-project-qs.html#ubuntu)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm

# bitbake will refuse to run as root, so create a utility user
RUN useradd -d /usr/local/src/yocto --create-home yocto

WORKDIR /usr/local/src/yocto/

RUN git clone -b dizzy          http://git.yoctoproject.org/git/poky
RUN git clone -b read-only-root https://github.com/thenewwazoo/meta-web-kiosk
RUN git clone -b dizzy          http://git.yoctoproject.org/git/meta-fsl-arm
RUN git clone -b dizzy          https://github.com/Freescale/meta-fsl-arm-extra
RUN git clone                   https://github.com/thenewwazoo/meta-luciddg-kiosk.git

# Copy relevant OE environemtn configuration files
ADD build/ /usr/local/src/yocto/build/

# Put the build wrapper script in place
ADD make.sh /usr/local/src/yocto/

# Workaround Docker bug #7537
RUN chown -R yocto:yocto /usr/local/src/yocto/

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init", "--", "sudo", "-u", "yocto", "-i", "/usr/local/src/yocto/make.sh"]
