FROM ubuntu:20.04
LABEL com.plutoverif.version="1.0"

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN  apt-get update \
  && apt-get install -y lsb-core wget make m4 build-essential patch unzip git libgmp3-dev \
  && rm -rf /var/lib/apt/lists/*
  
RUN apt-get update \ 
    && apt-get install -y llvm-10-dev libclang-10-dev texinfo libtool-bin autoconf automake pkg-config libgtk-3-dev flex bison \
  && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/FileCheck FileCheck /usr/bin/FileCheck-10 100 \
    && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-10 100

COPY . /pluto/

WORKDIR /pluto/

RUN git fetch origin && git reset --hard origin/master && git clean -d -f
RUN git submodule init && git submodule update
RUN ./autogen.sh && ./configure 
RUN make && make install

ENTRYPOINT ["bash"]
