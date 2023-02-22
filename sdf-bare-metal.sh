
export HPS_HOME=/sdf/group/hps/users/eichl008/hps

# keep using Cam's java
export JAVA_HOME=/sdf/group/hps/users/bravo/src/jdk-15.0.1
export PATH=/sdf/group/hps/users/bravo/src/jdk-15.0.1/bin:/sdf/group/hps/users/bravo/src/apache-maven-3.6.3/bin:$HOME/.local/bin:$PATH

# using Cam's GSL
if [ -z $GSL_ROOT_DIR ]; then
  export GSL_ROOT_DIR=/sdf/group/hps/users/bravo/src/gsl-2.6/install
  export LD_LIBRARY_PATH=${GSL_ROOT_DIR}/lib:$LD_LIBRARY_PATH
fi

#Setup Env
source /opt/rh/devtoolset-8/enable
if [ -z $LCIO_DIR ]; then
  export LCIO_DIR=/sdf/group/hps/users/eichl008/hps/lcio/install
  export LCIO_INCLUDE_DIRS=$LCIO_DIR/include
  export IO_LCIO_LIBRARY=$LCIO_DIR/lib/liblcio.so
  export LD_LIBRARY_PATH=$LCIO_DIR/lib:$LD_LIBRARY_PATH
  export PATH=$LCIO_DIR/bin:$PATH
  source ${HPS_HOME}/lcio/setup.sh
fi

if [ -z $HPSMC_DIR ]; then
  source ${HPS_HOME}/mc/install/bin/hps-mc-env.sh
fi

if [ -z $ROOTSYS ]; then
  #source ${HPS_HOME}/../root/install/bin/thisroot.sh
  source /sdf/group/hps/users/bravo/src/root/buildV62202/bin/thisroot.sh
fi

if [ -z $HPSTR_BASE ]; then
  if [ -d ${HPS_HOME}/hpstr/install/bin ]; then
    # there is a hpstr install
    if [ -f ${HPS_HOME}/hpstr/install/bin/setup.sh ]; then
      # older branch with legacy env script
      source ${HPS_HOME}/hpstr/install/bin/setup.sh
    elif [ -f ${HPS_HOME}/hpstr/install/bin/hpstr-env.sh ]; then
      # newer branch
      source ${HPS_HOME}/hpstr/install/bin/hpstr-env.sh
    else
      echo "ERROR: Can't deduce hpstr env script location."
    fi
  fi
fi

#Alias to make things easier
alias mvnclbd='mvn clean install -DskipTests=true -Dcheckstyle.skip'

