FROM node:8.4.0

RUN echo "deb http://ftp.ru.debian.org/debian/ jessie-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list && \
    echo "deb http://ftp.ru.debian.org/debian/ jessie main contrib non-free"           > /etc/apt/sources.list && \
    echo "deb http://ftp.ru.debian.org/debian/ jessie-updates main contrib non-free"   >> /etc/apt/sources.list &&\
    echo "deb http://security.debian.org jessie/updates main contrib non-free"         >> /etc/apt/sources.list


RUN apt-get update && apt-get install  locales-all  -y \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install  -t jessie-backports  -y \
     openjdk-8-jdk \
     git \
     curl \
  && rm -rf /var/lib/apt/lists/*

ENV LEIN_VERSION=2.7.1
ENV LEIN_INSTALL=/usr/local/bin/

WORKDIR /tmp

# Download the whole repo as an archive
RUN mkdir -p $LEIN_INSTALL \
  && wget -q https://github.com/technomancy/leiningen/archive/$LEIN_VERSION.tar.gz \
  && echo "Comparing archive checksum ..." \
  && echo "876221e884780c865c2ce5c9aa5675a7cae9f215 *$LEIN_VERSION.tar.gz" | sha1sum -c - \

  && mkdir ./leiningen \
  && tar -xzf $LEIN_VERSION.tar.gz  -C ./leiningen/ --strip-components=1 \
  && mv leiningen/bin/lein-pkg $LEIN_INSTALL/lein \
  && rm -rf $LEIN_VERSION.tar.gz ./leiningen \

  && chmod 0755 $LEIN_INSTALL/lein \

# Download and verify Lein stand-alone jar
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip \
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip.asc \

  && gpg --keyserver pool.sks-keyservers.net --recv-key 2E708FB2FCECA07FF8184E275A92E04305696D78 \
  && echo "Verifying Jar file signature ..." \
  && gpg --verify leiningen-$LEIN_VERSION-standalone.zip.asc \

# Put the jar where lein script expects
  && rm leiningen-$LEIN_VERSION-standalone.zip.asc \
  && mkdir -p /usr/share/java \
  && mv leiningen-$LEIN_VERSION-standalone.zip /usr/share/java/leiningen-$LEIN_VERSION-standalone.jar

ENV PATH=$PATH:$LEIN_INSTALL
ENV LEIN_ROOT 1

# Install clojure 1.8.0 so users don't have to download it every time
RUN echo '(defproject dummy "" :dependencies [[org.clojure/clojure "1.8.0"]])' > project.clj \
  && lein deps && rm project.clj

RUN npm install firebase-tools
