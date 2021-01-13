FROM alpine

WORKDIR /tmp
RUN apk update && apk upgrade && \
    apk add --no-cache tini git autoconf automake build-base linux-headers \
    libjpeg-turbo-dev libmicrohttpd-dev libzip-dev ffmpeg-dev gettext-dev \
    libmicrohttpd ffmpeg gettext libjpeg-turbo tzdata curl bash unzip \
    alsa-utils httpie jq && \
    curl https://rclone.org/install.sh | bash && \
    git clone https://github.com/Motion-Project/motion.git && \
    cd motion && autoreconf -fiv && \
    ./configure && \
    make && make install && cd .. && rm -rf /motion && \
    apk del git autoconf automake build-base linux-headers libjpeg-turbo-dev \
    libmicrohttpd-dev libzip-dev ffmpeg-dev gettext-dev && \
    rm -rf /tmp/* /var/tmp/*

VOLUME [ "/usr/local/etc/motion", "/root/.config/rclone", \
         "/var/lib/motion", "/var/log/motion" ]

WORKDIR /usr/local/etc
RUN if [ ! -f motion/motion.conf ]; then cp -f motion/motion-dist.conf motion/motion.conf; fi && \
    sed -i 's/; target_dir value/target_dir \/var\/lib\/motion/' motion/motion.conf && \
    sed -i 's/; log_file value/log_file \/var\/log\/motion\/motion.log/' motion/motion.conf && \
    sed -i 's/; pid_file value/pid_file \/run\/motion\/motion.pid/' motion/motion.conf && \
    cp -rf motion motion-dist && \
    mkdir -p /run/motion && \
    mkdir -p /var/lib/motion && \
    mkdir -p /var/log/motion

COPY sh/* /usr/local/bin/

WORKDIR /var/lib/motion
ENTRYPOINT [ "tini", "-v", "--" ]
CMD motion-run
