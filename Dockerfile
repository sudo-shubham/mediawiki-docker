FROM php:7.2-apache

LABEL maintainer="Shubham Patel <shubhampatelsp812@gmail.com>"

# SELECT MEDIAWIKI VERSION
ENV MEDIAWIKI_VERSION 1.34.0
ENV MEDIAWIKI_MAJOR_VERSION 1.34

# INSTALL MEDIAWIKI DEPENDENCIES
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf && \
    apt-get update -y && \
    apt-get -y install git \
        wget \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libicu-dev \
        libpng-dev \
        zlib1g-dev \
        libwebp-dev \
        libxpm-dev \
        netcat

# INSTALL AND ENABLE PHP EXTENSIONS REQUIRED FOR MEDIAWIKI
RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
    --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir && \
    docker-php-ext-configure intl

RUN pecl install apcu-5.1.18 \
    && docker-php-ext-install gd \
    && docker-php-ext-install intl \
    && docker-php-ext-install mysqli \  
    && docker-php-ext-enable apcu

# DOWNLOAD AND EXTRACT MEDIAWIKI IN '/var/www/mediawiki'
RUN cd /var/www/ && \
    wget https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz && \
    tar -zxf mediawiki-${MEDIAWIKI_VERSION}.tar.gz && \
    rm mediawiki-${MEDIAWIKI_VERSION}.tar.gz && \
    mv /var/www/mediawiki-${MEDIAWIKI_VERSION}/ /var/www/mediawiki/ && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# SET FOLDER OWNERSHIP FOR APACHE
RUN chown -R www-data:www-data /var/www/mediawiki

# CHANGE APACHE DOCUMENT_ROOT TO MEDIAWIKI FOLDER
ENV APACHE_DOCUMENT_ROOT /var/www/mediawiki
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Export 80
EXPOSE 80

# Copy LocalSettings
# COPY ./LocalSettings.php /var/www/mediawiki

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /var/www/mediawiki

ENTRYPOINT ["/docker-entrypoint.sh"]

# Start Apache
CMD ["apache2-foreground"]