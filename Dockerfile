FROM library/debian

ARG USER_ID

RUN apt-get update && apt-get -y install apt-utils && apt-get -y install wget vim xz-utils bzip2 && apt-get clean

RUN wget https://github.com/ldc-developers/ldc/releases/download/v1.7.0-beta1/ldc2-1.7.0-beta1-linux-x86_64.tar.xz \
    -O /tmp/ldc2.tar.xz && \
  tar xvJf /tmp/ldc2.tar.xz -C /opt && \
  ln -s /opt/ldc2-1.7.0-beta1-linux-x86_64 /opt/ldc2 && \
  rm -f /tmp/ldc2.tar.xz

RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 \
    -O /tmp/gcc-arm-none-eabi.tar.bz2 && \
  tar xvjf /tmp/gcc-arm-none-eabi.tar.bz2 -C /opt && \
  ln -s /opt/gcc-arm-none-eabi-7-2017-q4-major /opt/gcc-arm-none-eabi && \
  rm -f /tmp/gcc-arm-none-eabi.tar.bz2
  
RUN useradd -u ${USER_ID} -m pidos && \
  echo 'export PATH=${PATH}:/opt/ldc2/bin:/opt/gcc-arm-none-eabi/bin' >> /etc/profile

RUN apt-get -y install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev build-essential && apt-get clean
RUN cd /usr/local/src && \
  git clone git://git.qemu-project.org/qemu.git && \
  cd ./qemu && \
  ./configure --target-list=aarch64-softmmu,arm-softmmu && \
  make && make install && make clean && \
  cd && rm -rf /usr/local/src/qemu

