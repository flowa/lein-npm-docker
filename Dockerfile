FROM clojure:lein-2.7.1
RUN \
    apt-get update -y \
&&  apt-get install -y curl \
&&  curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&&  apt-get install -y nodejs build-essential python

RUN npm install -g node-gyp
