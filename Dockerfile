FROM library/debian

RUN apt-get update && \
  apt-get -y install wget && \
  wget http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list && \
  apt-get update && apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring && apt-get update && \
  apt-get -y install dub ldc

