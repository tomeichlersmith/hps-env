FROM ubuntu:20.04
LABEL ubuntu.version="20.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

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
        jq \
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
        libgsl-dev \
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
        python2 \
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
        cmake==3.26
LABEL cmake.version="3.26"
LABEL python.verson="3.8.10"
LABEL gnu.version="9.4.0"

###############################################################################
# Source-Code Downloading Method
#   mkdir src && ${__wget} <url-to-tar.gz-source-archive> | ${__untar} src
#
#   Adapted from acts-project/machines
###############################################################################
ENV __wget wget -q -O -
ENV __untar tar -xz --strip-components=1 --directory 
ENV __prefix /usr/local

###############################################################################
# java and its build tool maeven
#   both are just unpacking precompiled binaries for Linux into /usr/local
#   and then setting appropriate environment variables
###############################################################################
LABEL java.version="15.1.0"
LABEL mvn.version="3.9.1"
ENV JAVA_HOME=/usr/local/java
ENV MVN_HOME=/usr/local/mvn
ENV PATH=${JAVA_HOME}/bin:${MVN_HOME}/bin:${PATH}
RUN mkdir ${JAVA_HOME} ${MVN_HOME} &&\
    ${__wget} --no-check-certificate \
      https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz |\
      ${__untar} ${JAVA_HOME} &&\
    ${__wget} --no-check-certificate \
      https://archive.apache.org/dist/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz |\
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

################################################################################
# Xerces-C 
################################################################################
LABEL xercesc.version="3.2.5"
RUN mkdir src &&\
    ${__wget} http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.5.tar.gz |\
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
ENV GEANT4=v10.6.1
LABEL geant4.version="${GEANT4}"
RUN mkdir src &&\
    ${__wget} https://github.com/geant4/geant4/archive/${GEANT4}.tar.gz |\
      ${__untar} src &&\
    cmake \
        -DGEANT4_USE_SYSTEM_EXPAT=OFF \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DGEANT4_USE_OPENGL_X11=OFF \
        -DGEANT4_USE_QT=OFF \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
        &&\
    cmake --build src/build --target install -- -j 4 &&\
    rm -rf src 
ENV G4NEUTRONHPDATA="${__prefix}/share/Geant4-10.6.1/data/G4NDL4.6"
ENV G4LEDATA="${__prefix}/share/Geant4-10.6.1/data/G4EMLOW7.9.1"
ENV G4LEVELGAMMADATA="${__prefix}/share/Geant4-10.6.1/data/PhotonEvaporation5.5"
ENV G4RADIOACTIVEDATA="${__prefix}/share/Geant4-10.6.1/data/RadioactiveDecay5.4"
ENV G4PARTICLEXSDATA="${__prefix}/share/Geant4-10.6.1/data/G4PARTICLEXS2.1"
ENV G4PIIDATA="${__prefix}/share/Geant4-10.6.1/data/G4PII1.3"
ENV G4REALSURFACEDATA="${__prefix}/share/Geant4-10.6.1/data/RealSurface2.1.1"
ENV G4SAIDXSDATA="${__prefix}/share/Geant4-10.6.1/data/G4SAIDDATA2.0"
ENV G4ABLADATA="${__prefix}/share/Geant4-10.6.1/data/G4ABLA3.1"
ENV G4INCLDATA="${__prefix}/share/Geant4-10.6.1/data/G4INCL1.0"
ENV G4ENSDFSTATEDATA="${__prefix}/share/Geant4-10.6.1/data/G4ENSDFSTATE2.2"

###############################################################################
# HepPDT
###############################################################################
LABEL heppdt.version="3.04.01"
RUN git clone https://github.com/slaclab/heppdt src &&\
    cd src &&\
    ./configure \
      --prefix=${__prefix} \
      --disable-shared \
    && make install &&\
    cd / && rm -rf src

###############################################################################
# GDML
#   We need to write the C++ standard into the CMakeLists as a compiler
#   definition because the current CMakeLists.txt code doesn't properly
#   handle applying the Geant4 compiler definitions (allowing them to
#   overwrite the definitions deduced by CMake) /and/ a patch to the GCC STD
#   library now generates a compiler error when gdml tries to access a
#   certain header without C++11 std active.
###############################################################################
LABEL gdml.version="3.1.2"
RUN git clone https://github.com/slaclab/gdml src &&\
    sed -i '70i ADD_DEFINITIONS("-std=c++11")' src/CMakeLists.txt &&\
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
ENV LCDD_DIR=${__prefix}

###############################################################################
# slic
#   Default slic install for folks not needing to develop it.
#   Also set the GDML_SCHEMA_DIR environment variable so slic knows
#   where the pre-downloaded schema files are
###############################################################################
LABEL slic.version="v6.1.1"
RUN git clone --depth 1 --branch v6.1.1 \
      https://github.com/slaclab/slic.git src &&\
    cmake \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -DINSTALL_DOC=OFF \
      -DWITH_GEANT4_UIVIS=OFF \
      -B src/build \
      -S src &&\
    cmake --build src/build --target install &&\
    rm -rf src
ENV GDML_SCHEMA_DIR=${__prefix}/share

###############################################################################
# download and unpack the fieldmaps
#   destination is chosen to be what is expected from hps-mc defaults
###############################################################################
RUN git clone https://github.com/JeffersonLab/hps-fieldmaps ${__prefix}/share/fieldmap &&\
    cd ${__prefix}/share/fieldmap &&\
    ./unzip.sh

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
      -DCMAKE_CXX_STANDARD=17 \
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
LABEL gbl.version="V03-01-00"
RUN git clone --depth 1 --branch V03-01-00 \
      https://gitlab.desy.de/claus.kleinwort/general-broken-lines.git &&\
    cmake \
      -B general-broken-lines/build \
      -S general-broken-lines/cpp \
      -DCMAKE_INSTALL_PREFIX=/usr/local &&\
    cmake \
      --build general-broken-lines/build \
      --target install &&\
    rm -rf general-broken-lines

###############################################################################
# MillepedeII
#   Used for tracker alignment
###############################################################################
LABEL millepedeII.version="V04-13-01"
RUN git clone --depth 1 --branch V04-13-01 \
      https://gitlab.desy.de/claus.kleinwort/millepede-ii.git &&\
    cd millepede-ii &&\
    sed -i 's|^PREFIX =.*$|PREFIX = /usr/local|' Makefile &&\
    make install &&\
    cd / && rm -rf millepede-ii

###############################################################################
# hps-java
#   need to choose and install a version of hps-java
#   not sure what the best way to define install destination
#   for a java project is
###############################################################################
LABEL hps-java.version="5.2.1"
RUN mkdir ${__prefix}/hps &&\
    git clone https://github.com/JeffersonLab/hps-java ${__prefix}/hps/java \
        --branch hps-java-5.2.1 &&\
    cd ${__prefix}/hps/java &&\
    mvn \
      -DskipTests \
      -Dcheckstyle.skip \
    &&\
    cp -t ${__prefix}/hps/java/ \
      ~/.m2/repository/org/lcsim/lcio/2.7.4-SNAPSHOT/lcio-2.7.4-SNAPSHOT-bin.jar &&\
    find distribution/target -type f -name '*-bin.jar'
ENV HPS_JAVA_BIN_JAR=${__prefix}/hps/java/distribution/target/hps-distribution-5.2.1-bin.jar

###############################################################################
# install hps-mc for its recipes
#   use its CMake to copy in MadGraph as well as stdhep
###############################################################################
LABEL hps-mc.version="HEAD"
RUN git clone https://github.com/JeffersonLab/hps-mc src &&\
    cmake \
      -DHPSMC_ENABLE_STDHEP=ON \
      -DHPSMC_ENABLE_MADGRAPH=ON \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -B src/build \
      -S src &&\
    cmake --build src/build --target install &&\
    rm -rf src
ENV PYTHONPATH=${PYTHONPATH}:${__prefix}/lib/python
ENV HPSMC_DIR=${__prefix}
# copy in a hps-mc config file that users can supply when
# running hps-mc inside this container
COPY ./container.cfg /usr/local/share/

###############################################################################
# install hpstr for tuplization
###############################################################################
LABEL hpstr.version="ptrless:v0.1.1"
RUN git clone https://github.com/tomeichlersmith/hpstr src \
        --branch v0.1.1 \
        --depth 1 &&\
    cmake \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src &&\
    cmake --build src/build --target install &&\
    rm -rf src

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
#   Need to update pip first
###############################################################################
RUN python3 -m pip install --upgrade --no-cache-dir \
        pip &&\
    python3 -m pip install --upgrade --no-cache-dir \
        autopep8 \
        Cython \
        jinja2 \
        uproot \
        numpy \
        matplotlib \
        mplhep \
        pandas \
        psutil \
        pycodestyle \
        Sphinx \
        awkward \
        "hist[plot]" \
        "typer[all]" \
        vector \
        jupyterlab
