
FROM ubuntu:20.04
LABEL ubuntu.version="20.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

###############################################################################
# Source-Code Downloading Method
#   mkdir src && ${__wget} <url-to-tar.gz-source-archive> | ${__untar} src
#
#   Adapted from acts-project/machines
###############################################################################
ENV __wget wget -q -O -
ENV __untar tar -xz --strip-components=1 --directory 
ENV __prefix /usr/local

# All init scripts in this directory will be run upon entry into container
ENV __hep_env_script_d__ /etc/hep-container-end.d
RUN mkdir ${__hep_env_script_d__}

# this directory is where folks should "install" code compiled with the container
ENV EXTERNAL_INSTALL_DIR /externals
ENV PATH="${EXTERNAL_INSTALL_DIR}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${EXTERNAL_INSTALL_DIR}/lib"
ENV PYTHONPATH="${EXTERNAL_INSTALL_DIR}/lib:${EXTERNAL_INSTALL_DIR}/python:${EXTERNAL_INSTALL_DIR}/lib/python"
ENV CMAKE_PREFIX_PATH="${EXTERNAL_INSTALL_DIR}" 

#run environment setup when docker container is launched and decide what to do from there
COPY ./entry.sh /etc/
RUN chmod 755 /etc/entry.sh
ENTRYPOINT ["/etc/entry.sh"]

# First install any required dependencies from ubuntu repos
# Ongoing documentation for this list is in docs/ubuntu-packages.md
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        binutils \
        ca-certificates \
        fonts-freefont-ttf \
        g++-7 \
        gcc-7 \
        git \
        libfftw3-dev \
        libfreetype6-dev \
        libftgl-dev \
        libgif-dev \
        libgl1-mesa-dev \
        libgl2ps-dev \
        libglew-dev \
        libglu-dev \
        libjpeg-dev \
        liblz4-dev \
        liblzma-dev \
        libpcre++-dev \
        libpng-dev \
        libssl-dev \
        libx11-dev \
        libxext-dev \  
        libxft-dev \
        libxml2-dev \
        libxmu-dev \
        libxpm-dev \
        libz-dev \
        libzstd-dev \
        locales \
        make \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        python-is-python3 \
        srm-ifce-dev \
        wget \
    && rm -rf /var/lib/apt/lists/* &&\
    apt-get autoremove --purge &&\
    apt-get clean all &&\
    python3 -m pip install --upgrade --no-cache-dir cmake

###############################################################################
# java and its build tool maeven
#   both are just unpacking precompiled binaries for Linux into /usr/local
#   and then setting appropriate environment variables
###############################################################################
LABEL java.version="15.1.0"
LABEL mvn.version="3.8.6"
ENV JAVA_HOME=/usr/local/java
ENV MVN_HOME=/usr/local/mvn
ENV PATH=${PATH}:${JAVA_HOME}/bin:${MVN_HOME}/bin
RUN mkdir ${JAVA_HOME} ${MVN_HOME} &&\
    ${__wget} https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz |\
      ${__untar} ${JAVA_HOME} &&\
    ${__wget} https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz |\
      ${__untar} ${MVN_HOME}

###############################################################################
# LCIO
###############################################################################
LABEL lcio.verision="hps-lcio:master"
ENV LCIO_DIR=${__prefix}
ENV LCIO_INCLUDE_DIRS=${LCIO_DIR}/include
ENV IO_LCIO_LIBRARY=${LCIO_DIR}/lib/liblcio.so
ENV LD_LIBRARY_PATH=${LCIO_DIR}/lib:${LD_LIBRARY_PATH}
RUN mkdir src &&\
    git clone https://github.com/JeffersonLab/hps-lcio.git src &&\
    mkdir src/build &&\
    cd src/build &&\
    cmake \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      .. &&\
    make install &&\
    cd /src/ &&\
    mvn clean install -DskipTests -Dcheckstyle.skip &&\
    ldconfig ${__prefix}/lib &&\
    cd / && rm -rf src

###############################################################################
# CERN's ROOT
###############################################################################
LABEL root.version="6.22.08"
RUN mkdir src &&\
    ${__wget} https://root.cern/download/root_v6.22.08.source.tar.gz |\
     ${__untar} src &&\
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -Dgminimal=ON \
      -Dgdml=ON \
      -Dopengl=ON \
      -Dpyroot=ON \
      -Dgnuinstall=ON \
      -Dxrootd=OFF \
      -B build \
      -S src \
    && cmake --build build --target install &&\
    ln -s /usr/local/bin/thisroot.sh ${__hep_env_script_d__}/thisroot.sh &&\
    rm -rf build src

###############################################################################
# Eigen
###############################################################################
LABEL eigen.version=3.4.0
RUN mkdir src &&\
    ${__wget} https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz |\
      ${__untar} src &&\
    cmake \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
    &&\
    cmake \
        --build src/build \
        --target install \
    &&\
    rm -rf src 

###############################################################################
# GeneralBrokenLines
###############################################################################
LABEL gbl.version=2.2.0
RUN mkdir src &&\
    ${__wget} https://github.com/pbutti/GeneralBrokenLines/tarball/master |\
      ${__untar} src &&\
    cmake \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -B src/cpp/build \
      -S src/cpp \
    &&\
    cmake \
      --build src/cpp/build \
      --target install \
    &&\
    rm -rf src

