FROM ubuntu/apache2:2.4-20.04_edge

ARG DEBIAN_FRONTEND=noninteractive

ENV DB_MYSQL_HOST db
ENV DB_MYSQL_PORT 3306
ENV DB_MYSQL_NAME avideo
ENV DB_MYSQL_USER avideo
ENV DB_MYSQL_PASSWORD avideo

ENV VERSION_AVIDEO 11.1.1
ENV VERSION_ENCODER 3.7

ENV SERVER_NAME avideo.localhost
ENV CREATE_TLS_CERTIFICATE yes
ENV TLS_CERTIFICATE_FILE /etc/apache2/ssl/localhost.crt
ENV TLS_CERTIFICATE_KEY /etc/apache2/ssl/localhost.key

# Retrieve package list
RUN apt update

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

COPY apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY apache/docker-entrypoint /usr/local/bin/docker-entrypoint

# Configure AVideo
RUN chmod 755 /usr/local/bin/docker-entrypoint && \
    cd /var/www/html && \
    git config --global advice.detachedHead false && \
    git clone -b $VERSION_AVIDEO  --depth 1 https://github.com/WWBN/AVideo.git && \
    git clone -b $VERSION_ENCODER --depth 1 https://github.com/WWBN/AVideo-Encoder.git && \
    pip3 install youtube-dl && \
    cd /var/www/html/AVideo/plugin/User_Location/install && \
    unzip install.zip && \
    a2enmod rewrite expires headers ssl xsendfile

VOLUME /var/www/tmp
RUN mkdir -p /var/www/tmp && \
    chown www-data:www-data /var/www/tmp && \
    chmod 777 /var/www/tmp

VOLUME /var/www/html/AVideo/plugin
RUN mkdir -p /var/www/AVideo/plugin && \
    chown www-data:www-data /var/www/html/AVideo/plugin && \
    chmod 755 /var/www/html/AVideo/plugin

VOLUME /var/www/html/AVideo/videos
RUN mkdir -p /var/www/html/AVideo/videos && \
    chown www-data:www-data /var/www/html/AVideo/videos && \
    chmod 777 /var/www/html/AVideo/videos

WORKDIR /var/www/html/AVideo/

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["apache2-foreground"]
HEALTHCHECK --interval=60s --timeout=55s --start-period=1s CMD curl --fail https://localhost/ || exit 1  
