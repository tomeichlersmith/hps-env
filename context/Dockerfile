
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

# First install any required dependencies from ubuntu repos
# Ongoing documentation for this list is in docs/ubuntu-packages.md
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        apt-utils \
        bc \
        binutils \
        ca-certificates \
        curl \
        dialog \
        diffutils \
        findutils \
        default-jre \
        fonts-freefont-ttf \
        g++ \
        gcc \
        gfortran \
        gnupg2 \
        git \
        less \
        libafterimage-dev \
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
        libnss-myhostname \
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
        lsof \
        locales \
        make \
        ncurses-base \
        passwd \
        pinentry-curses \
        procps \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        python-is-python3 \
        srm-ifce-dev \
        sudo \
        time \
        util-linux \
        wget \
    && rm -rf /var/lib/apt/lists/* &&\
    apt-get autoremove --purge &&\
    apt-get clean all &&\
    python3 -m pip install --no-cache-dir \
        cmake==3.25 \

###############################################################################
# java and its build tool maeven
#   both are just unpacking precompiled binaries for Linux into /usr/local
#   and then setting appropriate environment variables
###############################################################################
LABEL java.version="15.1.0"
LABEL mvn.version="3.9.0"
ENV JAVA_HOME=/usr/local/java
ENV MVN_HOME=/usr/local/mvn
ENV PATH=${JAVA_HOME}/bin:${MVN_HOME}/bin:${PATH}
RUN mkdir ${JAVA_HOME} ${MVN_HOME} &&\
    ${__wget} https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz |\
      ${__untar} ${JAVA_HOME} &&\
    ${__wget} https://dlcdn.apache.org/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz |\
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
    cd / && rm -rf src

###############################################################################
# CERN's ROOT
#   The ENV variables needed downstream for ROOT running and dedection were
#   manually extracted from the thisroot.sh script.
#   Since we are installing to /usr/local/{bin,lib,...} we can avoid some
#   of the paths: PATH, LD_LIBRARY_PATH (running ldconfig later)
###############################################################################
LABEL root.version="6.22.08"
RUN mkdir src &&\
    ${__wget} https://root.cern/download/root_v6.22.08.source.tar.gz |\
     ${__untar} src &&\
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -Dgminimal=ON \
      -Dasimage=ON \
      -Dgdml=ON \
      -Dopengl=ON \
      -Dpyroot=ON \
      -Dgnuinstall=ON \
      -Dxrootd=OFF \
      -B build \
      -S src \
    && cmake --build build --target install &&\
    echo "/usr/local/lib/root" > /etc/ld.so.conf.d/cern-root.conf &&\
    rm -rf build src
ENV ROOTSYS=${__prefix}
ENV PYTHONPATH=${ROOTSYS}/lib/root:${PYTHONPATH}
ENV JUPYTER_PATH=${ROOTSYS}/etc/notebook:${JUPYTER_PATH}
ENV JUPYTER_CONFIG_DIR=${ROOTSYS}/etc/notebook:${JUPYTER_CONFIG_DIR}
ENV CLING_STANDARD_PCH=none

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
    echo "# removed on purpose" > src/cpp/cmake/ilcsoft_default_install_prefix.cmake &&\
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

################################################################################
# Xerces-C 
################################################################################
LABEL xercesc.version="3.2.3"
RUN mkdir src &&\
    ${__wget} http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.3.tar.gz |\
      ${__untar} src &&\
    cmake -B src/build -S src -DCMAKE_INSTALL_PREFIX=${__prefix} &&\
    cmake --build src/build --target install &&\
    rm -rf src

###############################################################################
# Geant4
#
#   The normal ENV variables can be ommitted since we are installing to
#   a system path. We just need to copy the environment variables defining
#   the location of datasets.
###############################################################################
ENV GEANT4=v10.7.4
LABEL geant4.version="${GEANT4}"
RUN mkdir src &&\
    ${__wget} https://github.com/geant4/geant4/archive/${GEANT4}.tar.gz |\
      ${__untar} src &&\
    cmake \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DGEANT4_USE_OPENGL_X11=ON \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
        &&\
    cmake --build src/build --target install &&\
    rm -rf src 
ENV G4NEUTRONHPDATA="${__prefix}/share/Geant4-10.7.4/data/G4NDL4.6"
ENV G4LEDATA="${__prefix}/share/Geant4-10.7.4/data/G4EMLOW7.13"
ENV G4LEVELGAMMADATA="${__prefix}/share/Geant4-10.7.4/data/PhotonEvaporation5.7"
ENV G4RADIOACTIVEDATA="${__prefix}/share/Geant4-10.7.4/data/RadioactiveDecay5.6"
ENV G4PARTICLEXSDATA="${__prefix}/share/Geant4-10.7.4/data/G4PARTICLEXS3.1.1"
ENV G4PIIDATA="${__prefix}/share/Geant4-10.7.4/data/G4PII1.3"
ENV G4REALSURFACEDATA="${__prefix}/share/Geant4-10.7.4/data/RealSurface2.2"
ENV G4SAIDXSDATA="${__prefix}/share/Geant4-10.7.4/data/G4SAIDDATA2.0"
ENV G4ABLADATA="${__prefix}/share/Geant4-10.7.4/data/G4ABLA3.1"
ENV G4INCLDATA="${__prefix}/share/Geant4-10.7.4/data/G4INCL1.0"
ENV G4ENSDFSTATEDATA="${__prefix}/share/Geant4-10.7.4/data/G4ENSDFSTATE2.3"

###############################################################################
# HepPDT
###############################################################################
LABEL heppdt.version="3.04.01"
RUN git clone https://github.com/slaclab/heppdt src &&\
    cd src &&\
    ./configure \
      --prefix=${__prefix} \
      --disable-static \
    && make install &&\
    cd / && rm -rf src

###############################################################################
# GDML
###############################################################################
LABEL gdml.version="3.1.2"
RUN git clone https://github.com/slaclab/gdml src &&\
    cmake \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -B src/build \
      -S src \
    &&\
    cmake \
      --build src/build \
      --target install \
    && rm -rf src

###############################################################################
# LCDD
###############################################################################
LABEL lcdd.version="5.0.0"
RUN git clone https://github.com/slaclab/lcdd src &&\
    cmake \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -B src/build \
      -S src \
    &&\
    cmake \
      --build src/build \
      --target install \
    && rm -rf src

###############################################################################
# MillepedeII
#   Used for tracker alignment
#   No publicly availabe repository so we have to carry around the tarball here
###############################################################################
LABEL millepedeII.version="unknown"
ADD ./MillepedeII.tar.gz /src/
RUN cd /src/MillepedeII/ &&\
    sed -i 's|^PREFIX =.*$|PREFIX = /usr/local|' Makefile &&\
    make install &&\
    cd / && rm -rf src

###############################################################################
# Generate the linker cache
#    This should go AFTER all compiled dependencies so that the ld cache 
#    contains all of them.
#    Ubuntu includes /usr/local/lib in the linker cache generation by default,
#    so dependencies just need to write a ld conf file if their libs do not
#    get installed to that directory (e.g. ROOT)
###############################################################################
RUN ldconfig -v

###############################################################################
# Extra Python packages
###############################################################################
RUN python3 -m pip install --upgrade --no-cache-dir \
        Cython \
        uproot \
        numpy \
        matplotlib \
        mplhep \
        pandas \
        "typer[all]"
