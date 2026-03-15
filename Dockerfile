ARG PLUTO_GIT_REMOTE=https://github.com/verif-scop/pluto.git
ARG PLUTO_GIT_COMMIT=unknown

FROM ubuntu:20.04

ARG PLUTO_GIT_REMOTE
ARG PLUTO_GIT_COMMIT

LABEL com.plutoverif.version="1.0" \
      com.plutoverif.remote="${PLUTO_GIT_REMOTE}" \
      com.plutoverif.commit="${PLUTO_GIT_COMMIT}"

ENV PLUTO_GIT_REMOTE="${PLUTO_GIT_REMOTE}" \
    PLUTO_GIT_COMMIT="${PLUTO_GIT_COMMIT}"

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

RUN if [ -d .git ]; then \
      actual_commit="$(git rev-parse HEAD)"; \
      if [ "$PLUTO_GIT_COMMIT" != "unknown" ] && [ "$actual_commit" != "$PLUTO_GIT_COMMIT" ]; then \
        echo "Pluto commit mismatch: expected $PLUTO_GIT_COMMIT got $actual_commit" >&2; \
        exit 1; \
      fi; \
    fi
RUN git submodule update --init --recursive
RUN ./autogen.sh && ./configure 
RUN make && make install

ENTRYPOINT ["bash"]
