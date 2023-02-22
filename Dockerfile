FROM debian:buster-slim

# https://docs.mopidy.com/en/latest/installation/debian/

RUN set -ex \
 && apt update \
 && apt install -y wget curl dumb-init gstreamer1.0-plugins-bad

RUN mkdir -p /usr/local/share/keyrings
RUN wget -q -O /usr/local/share/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy.gpg
RUN wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list
# RUN add-apt-repository ppa:yt-dlp/stable

RUN set -ex \ 
 && apt update \
 && apt install -y mopidy python3-pip

RUN pip3 install \
    youtube-dl \
    yt-dlp \
    mopidy-iris \
    mopidy-youtube \
    mopidy-local \
    mopidy-mpd 

####

# Soft link from root config dir to root dir
RUN set -ex \
 && mkdir -p /var/lib/mopidy/.config \
 && ln -s /config /var/lib/mopidy/.config/mopidy

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy
RUN set -ex \
 && usermod -G audio,sudo mopidy \
 && chown mopidy:audio -R $HOME /entrypoint.sh \
 && chmod go+rwx -R $HOME /entrypoint.sh


# Set puid and pgid
RUN groupmod -g 1000 audio && usermod -u 1000 -g 1000 mopidy

# Runs as mopidy user by default.
USER mopidy
# USER root

# Basic check,
# RUN /usr/bin/dumb-init /entrypoint.sh /usr/local/bin/mopidy --version
RUN /usr/bin/dumb-init /entrypoint.sh /usr/bin/mopidy --version

# VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
# CMD ["/usr/local/bin/mopidy"]
CMD ["/usr/bin/mopidy"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1




