FROM ubuntu/apache2:2.4-20.04_edge

ARG DEBIAN_FRONTEND=noninteractive

ENV DB_MYSQL_HOST db
ENV DB_MYSQL_PORT 3306
ENV DB_MYSQL_USER avideo
ENV DB_MYSQL_PASSWORD avideo
ENV DB_MYSQL_NAME avideo

# Update OS
RUN apt update && \
    apt upgrade -y

# Install dependencies
RUN apt install -y --no-install-recommends \
      systemctl \
      apt-transport-https \
      lsb-release \
      logrotate \
      git \
      unzip \
      curl \
      wget && \
    apt install -y \
      sshpass \
      net-tools \
      ffmpeg \
      libimage-exiftool-perl \
      libapache2-mod-xsendfile \
      libapache2-mod-php7.4 \
      python \
      build-essential \
      make \
      libpcre3 \
      libpcre3-dev \
      libssl-dev \
      python3-pip \ 
      php7.4 \
      php7.4-common \
      php7.4-cli \
      php7.4-json \
      php7.4-mbstring \
      php7.4-curl \
      php7.4-mysql \
      php7.4-bcmath \
      php7.4-xml \
      php7.4-gd \
      php7.4-zip \
      php7.4-intl

# Configure AVideo
RUN cd /var/www/html && \
    git clone https://github.com/WWBN/AVideo.git && \
    git clone https://github.com/WWBN/AVideo-Encoder.git && \
    curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && \
    chmod a+rx /usr/local/bin/youtube-dl && \
    pip3 install youtube-dl && \
    pip3 install --upgrade youtube-dl && \
    cd /var/www/html/AVideo/plugin/User_Location/install && \
    unzip install.zip && \
    chmod 777 /var/www/html/AVideo/vendor/ezyang/htmlpurifier/library/HTMLPurifier/DefinitionCache/Serializer/ && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    cp /var/www/html/AVideo/deploy/apache/avideo.conf /etc/apache2/sites-enabled/avideo.conf && \
    a2enmod rewrite expires headers ssl xsendfile

VOLUME /var/www/tmp
RUN mkdir -p /var/www/tmp && \
    chown www-data:www-data /var/www/tmp && \
    chmod 777 /var/www/tmp

VOLUME /var/www/html/AVideo/plugin
RUN mkdir -p /var/www/AVideo/plugin && \
    chown www-data:www-data /var/www/html/AVideo/plugin && \
    chmod 755 /var/www/html/AVideo/plugin && \

VOLUME /var/www/html/AVideo/videos
RUN mkdir -p /var/www/html/AVideo/videos && \
    chown www-data:www-data /var/www/html/AVideo/videos && \
    chmod 777 /var/www/html/AVideo/videos

WORKDIR /var/www/html/AVideo/

CMD apachectl -D FOREGROUND
