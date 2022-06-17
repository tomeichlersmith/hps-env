#!/bin/bash

export __hps_env_sh_version="v0.1.0"

####################################################################################################
# hps-env.sh
#   This script is intended to define all the container aliases required
#   to interface with a hps-env container. These commands assume that the user
#     1. Has docker engine installed OR has singularity installed
#     2. Can run docker as a non-root user OR can run singularity build/run
#
#   SUGGESTION: Put something similar to the following in your '.bashrc',
#     '~/.bash_aliases', or '~/.bash_profile' so that you just have to 
#     run 'hps-env' to set-up this environment.
#
#   alias hps-env='source <full-path>/hps-env.sh; unalias hps-env'
#
#   The file $HOME/.hpsrc handles the default environment setup for the
#   container. Look there for persisting your custom settings.
####################################################################################################

####################################################################################################
# All of this setup requires us to be in a bash shell.
#   We add this check to make sure the user is in a bash shell.
####################################################################################################
if [[ "$0" != *"bash"* ]]; then
  echo "[hps-env.sh] [ERROR] You aren't in a bash shell. You are in '$0'."
  [[ "$SHELL" = *"bash"* ]] || echo "  You're default shell '$SHELL' isn't bash."
  return 1
fi

####################################################################################################
# __hps_has_required_engine
#   Checks if user has any of the supported engines for running containers
####################################################################################################
__hps_has_required_engine() {
  if hash docker &> /dev/null; then
    return 0
  elif hash singularity &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# check if user has a required engine
if ! __hps_has_required_engine; then
  echo "[hps-env.sh] [ERROR] You do not have docker or singularity installed!"
  return 1
fi

####################################################################################################
# __hps_which_os
#   Check what OS we are hosting the container on.
#   Taken from https://stackoverflow.com/a/8597411
#   and to integrate Windoze Subsystem for Linux: 
#     https://wiki.ubuntu.com/WSL#Running_Graphical_Applications
####################################################################################################
export HPS_CONTAINER_DISPLAY=""
__hps_which_os() {
  if uname -a | grep -q microsoft; then
    # Windoze Subsystem for Linux
    export HPS_CONTAINER_DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null)    
    return 0
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    export HPS_CONTAINER_DISPLAY="docker.for.mac.host.internal"
    return 0
  elif [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "freebsd"* ]]; then
    # Linux distribution
    export HPS_CONTAINER_DISPLAY=""
    return 0
  fi

  return 1
}

if ! __hps_which_os; then
  echo "[hps-env.sh] [WARN] Unable to detect OS Type from '${OSTYPE}' or '$(uname -a)'"
  echo "    You will *not* be able to run display-connected programs."
fi

####################################################################################################
# We have gotten here after determining that we definitely have a container runner 
# (either docker or singularity) and we have determined how to connect the display 
# (or warn the user that we can't) via the HPS_CONTAINER_DISPLAY variable.
#
#   All container-runners need to implement the following commands
#     - __hps_list_local : list images available locally
#     - __hps_container_clean : remove all containers and images on this machine
#     - __hps_container_config : print configuration of container
#     - __hps_run : give all arguments to container's entrypoint script
#         - mounts all directories in bash array HPS_CONTAINER_MOUNTS
#     - __hps_cache : change directory where image layers are cached
####################################################################################################

__hps_run_help() {
  cat<<\HELP
  USAGE:
    hps run <dir> <program> [<args>]

    We launch the container, mounting all of the directories stored in the HPS_CONTAINER_MOUNTS
    array, and then go to <dir> to execute <program> with its (optional) arguments <args>.

    We do not check if <dir> is available inside of the container or even if it is actually
    a directory outside the container.

    This is a low-level command and should not be used regularly.

  EXAMPLES:
    You can look at the entry script in this way.
      hps run /etc less entry.sh
    Or open up a shell
      hps run / /bin/bash
HELP
}

__hps_cache_help() {
  cat <<\HELP
  USAGE:
    hps cache <dir>

    Change the directory in which layers of images are cached for later use.

    This feature is only available on systems using singularity.

  EXAMPLES:
    Perhaps my home directory is too small and so I need to use a large scratch directory.
      hps cache /scratch/
HELP
}

# prefer docker, so we do that first
if hash docker &> /dev/null; then
  # List containers on our machine matching the passed sub-string
  __hps_list_local() {
    docker images -q "$1"
  }

  # Print container configuration
  #   SHA retrieval taken from https://stackoverflow.com/a/33511811
  __hps_container_config() {
    echo "Docker Version: $(docker --version)"
    echo "Docker Tag: ${HPS_IMAGE_TAG}"
    echo "  SHA: $(docker inspect --format='{{index .RepoDigests 0}}' ${HPS_IMAGE_TAG})"
    return 0
  }

  # Clean up local machine
  __hps_container_clean() {
    docker container prune -f || return $?
    docker image prune -a -f  || return $?
  }

  # Run the container
  __hps_run() {
    local _mounts=""
    for dir_to_mount in "${HPS_CONTAINER_MOUNTS[@]}"; do
      _mounts="$_mounts -v $dir_to_mount:$dir_to_mount"
    done
    docker run --rm -it  \
      -e DISPLAY=${HPS_CONTAINER_DISPLAY}:0 \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      ${HPS_CONTAINER_INSTALL:+-v ${HPS_CONTAINER_INSTALL}:/externals} \
      $_mounts \
      -u $(id -u ${USER}):$(id -g ${USER}) \
      $HPS_IMAGE_TAG "$@"
    return $?
  }

  __hps_cache() {
    echo "ERROR: Changing the image cache directory is only supported in singularity."
    return 1
  }
elif hash singularity &> /dev/null; then
  # List all '.sif' files in  directory
  __hps_list_local() {
    echo "ERROR: hps list local not implemented for singularity runners."
    return 1
  }

  # Print container configuration
  __hps_container_config() {
    echo "Singularity Version: $(singularity --version)"
    echo "Singularity Tag: docker://${HPS_IMAGE_TAG}"
    return 0
  }

  # Clean up local machine
  __hps_container_clean() {
    [[ ! -z ${SINGULARITY_CACHEDIR} ]] && rm -r $SINGULARITY_CACHEDIR || return $?
  }

  # Run the container
  __hps_run() {
    local csv_list="/tmp/.X11-unix:/tmp/.X11-unix${HPS_CONTAINER_INSTALL:+,${HPS_CONTAINER_INSTALL}:/externals}"
    for dir_to_mount in "${HPS_CONTAINER_MOUNTS[@]}"; do
      csv_list="$csv_list,$dir_to_mount"
    done
    singularity run --no-home --cleanenv \
      --bind ${csv_list} docker://${HPS_IMAGE_TAG} "$@"
    return $?
  }

  __hps_cache() {
    if [[ -d "$1" ]]; then
      export SINGULARITY_CACHEDIR="$1"
      return 0
    else
      echo "ERROR: '$1' is not a directory."
      return 1
    fi
  }
fi

####################################################################################################
# __hps_list
#   Get the docker tags for the repository
#   Taken from https://stackoverflow.com/a/39454426
# If passed repo-name is 'local',
#   the list of container options is runner-dependent
####################################################################################################
__hps_list_help() {
  cat<<\HELP
  USAGE:
    hps list <docker-repo> [<glob>]

    <docker-repo> is the repository of images you want to list the images of.
    <glob> is an optional globbing pattern (as in grep) to filter the list of image tags.

    For systems using docker, containers built on the local system can be tagged and you 
    can search these tags using <docker-repo>=local.

  EXAMPLES:
    List all of the tags in the default repository
      hps list tomeichlersmith/hps-env
    Only look at the tags that are root-based
      hps list tomeichlersmith/hps-env root*
    Look at tags already on local system (docker systems only)
      hps list local
HELP
}
__hps_list() {
  local _repo_name="$1"
  local _glob="$2"
  if [ "${_repo_name}" == "local" ]; then
    __hps_list_local ${_glob}
    return $?
  else
    #line-by-line description
    # download tag json
    # strip unnecessary information
    # break tags into their own lines
    # pick out tags using : as separator
    # get the tags matching the glob expression
    # put tags back onto same line
    wget -q https://registry.hub.docker.com/v1/repositories/${_repo_name}/tags -O -  |\
        sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' |\
        tr '}' '\n'  |\
        awk -F: '{print $3}' |\
        grep ${_glob:+*} |\
        tr '\n' ' '
    local rc=${PIPESTATUS[0]}
    echo "" #new line
    return ${rc}
  fi
}

####################################################################################################
# __hps_config
#   Print the configuration of the current setup
####################################################################################################
__hps_config() {
  echo "hps-env version: ${__hps_env_sh_version}"
  echo "uname: $(uname -a)"
  echo "OSTYPE: ${OSTYPE}"
  echo "Display Port: ${HPS_CONTAINER_DISPLAY}"
  echo "Container Mounts: ${HPS_CONTAINER_MOUNTS[@]}"
  __hps_container_config
  return $?
}

####################################################################################################
# __hps_is_mounted
#   Check if the input directory will be accessible by the container
####################################################################################################
__hps_is_mounted() {
  local full=$(cd "$1" && pwd -P)
  for _already_mounted in ${HPS_CONTAINER_MOUNTS[@]}; do
    if [[ $full/ = $_already_mounted/* ]]; then
      return 0
    fi
  done
  return 1
}

####################################################################################################
# __hps_use
#  Define which image to use when launching container
####################################################################################################
__hps_use_help() {
  cat<<\HELP
  USAGE:
    hps use <image-tag>

    <image-tag> can be the full docker image tag where the repo is included or
    just the short-tag (after the colon).

    We do not check if the input tag is connected to an existing image.

  EXAMPLES:
    hps use tomeichlersmith/hps-env:root-latest
    hps use root-v6.18
HELP
}
export HPS_IMAGE_TAG="tomeichlersmith/hps-env:latest"
__hps_use() {
  local _tag="$1"
  if [[ ${_tag} = *":"* ]]; then
    # full docker image tag was given
    export HPS_IMAGE_TAG=${_tag}
  else
    # only short-tag, keep repo from before
    export HPS_IMAGE_TAG="${HPS_IMAGE_TAG%:*}:${_tag}"
  fi
  return 0
}

####################################################################################################
# __hps_mount
#   Tell us to mount the passed directory to the container when we run
#   By default, we already mount the HOME directory, so none of
#   its subdirectories need to (or should be) specified.
####################################################################################################
__hps_mount_help() {
  cat<<\HELP
  USAGE:
    hps mount <directory>

    <directory> will be mounted to the container when it is run.
    An error is thrown if the input is not a directory and we check if the directory
    is a subdirectory of a directory already mounted (and do nothing if this is true).

    By default, we do not mount anything to the container. This makes the environment
    almost useless since you won't be able to persist any code you may write or read.

  EXAMPLES:
    It is common practice to simply mount the current directory, which you can do with
      hps mount .
HELP
}
export HPS_CONTAINER_MOUNTS=()
__hps_mount() {
  local _dir_to_mount="$1"
  
  if [[ ! -d $_dir_to_mount ]]; then
    __hps_mount_help
    echo "ERROR: $_dir_to_mount is not a directory!"
    return 1
  fi

  if __hps_is_mounted $_dir_to_mount; then
    echo "NOTE: $_dir_to_mount is already mounted"
    return 0
  fi

  HPS_CONTAINER_MOUNTS+=($(cd "$_dir_to_mount" && pwd -P))
  export HPS_CONTAINER_MOUNTS
  return 0
}

####################################################################################################
# __hps_install
#   Tell us where software compiled with the container will be installed to.
#   This directory is added to the various PATH variables to make linking/running easier.
####################################################################################################
__hps_install_help() {
  cat<<\HELP
  USAGE:
    hps install <directory>

    <directory> will be mounted to the container at a specific location which various
    *PATH* variables are pointed to.

    By default, there is no directory mounted in this way so software will not be 
    "findable" within the container.

    The environment variables that are included within the conatiner for this special
    directory are

      <directory>/lib is attached to LD_LIBRARY_PATH and PYTHONPATH
      <directory>/bin is attached to PATH
      <directory>/python is attached to PYTHONPATH
      <directory> is attached to CMAKE_PREFIX_PATH 

  EXAMPLES:
    It is common practice to define a shared install directory somewhere on your computer.

      hps install ~/.container-install

    And then you can use that directory as your install prefix when installing software.
HELP
}
export HPS_CONTAINER_INSTALL=""
__hps_install() {
  export HPS_CONTAINER_INSTALL=$(cd "$1" && pwd -P)
  return 0
}

####################################################################################################
# __hps_clean
#   Clean up the computing environment for hps
#   The input argument defines what should be cleaned
####################################################################################################
__hps_clean_help() {
  cat<<\HELP
  USAGE:
    hps clean (env | container | all)

    env       - unset the hps-env bash variables
    container - remove all containers and images from storage on this computer
    all       - do both 
HELP
}
__hps_clean() {
  _what="$1"
  case $_what in
    env|container|all)
      ;;
    *)
      echo "ERROR: '$_what' is an unrecognized hps clean option."
      return 1
      ;;
  esac

  local rc=0
  if [[ "$_what" = "container" ]] || [[ "$_what" = "all" ]]; then
    __hps_container_clean
    rc=$?
  fi

  # must be last so cleaning of source can look in hps base
  if [[ "$_what" = "env" ]] || [[ "$_what" = "all" ]]; then
    unset HPS_CONTAINER_MOUNTS
    unset HPS_CONTAINER_DISPLAY
  fi

  return ${rc}
}

####################################################################################################
# __hps_source
#   Run all the sub-commands in the provided file.
#   Ignore empty lines or lines starting with '#'
####################################################################################################
__hps_source_help() {
  cat<<\HELP
  USAGE:
    hps source <file>

    <file> has a list of commands in it that will each be given to the foundational 'hps' command.
    All empty lines and lines beginning with '#' are ignored.

    It is good practice to use full paths to directories and files inside of <file> because
    this command does not guartantee a location from which the commands in <file> are run.

  EXAMPLES:
    The hps-env.sh script uses this function to setup a default environment if the file $HOME/.hpsrc
    exists.

      hps source $HOME/.hpsrc
HELP
}
__hps_source() {
  if [[ ! -f "$1" ]]; then
    echo "ERROR: '$1' is not a file."
    return 1
  fi
  while read _subcmd; do
    if [[ -z "$_subcmd" ]] || [[ "$_subcmd" = \#* ]]; then
      continue
    fi
    hps $_subcmd || return $?
  done < $1
  cd - &> /dev/null
  return 0
}

####################################################################################################
# __hps_help
#   Print some helpful message to the terminal
####################################################################################################
__hps_help() {
  cat <<\HELP
  USAGE: 
    hps <command> [<argument> ...]

    <command> can either be an EXTERNAL command defined in the hps-env.sh script
    or a command that is defined within the container.

    The list of internal commands changes depending on what softwares are installed within
    the container image. Command internal commands are python, cmake, make, root, and rootbrowse.

  EXTERNAL COMMANDS:
    help    : Print this help message and exit
    config  : Print the current configuration of the container
    list    : List the tag options for the input container repository
    clean   : Reset hps computing environment
    cache   : Change the directory in which image layers are stored
    use     : Set image tag to use to run container
    mount   : Attach the input directory to the container when running
    install : Choose directory to install software compiled within container
    run     : Run a command at an input location in the container
    source  : Run the commands in the provided file through hps

  EXAMPLES:
    hps help
    hps list tomeichlersmith/hps-env
    hps clean container
    hps config
    hps use v1.0
    hps pull latest
    hps mount $HOME
    hps install .container-install
    hps run /etc cat entry.sh
    hps source $HOME/.hpsrc
    hps make install
    hps rootbrowse data.root
HELP
  return 0
}

####################################################################################################
# hps
#   The root command for users interacting with the hps container environment.
#   This function is really just focused on parsing CLI and going to the
#   corresponding subcommand.
#
#   There are lots of subcommands, go to those functions to learn the detail
#   about them.
####################################################################################################
hps() {
  # divide commands by outside/inside container and separate by number of arguments
  case $1 in
    # zero arguments
    help|config)
      __hps_$1
      return 0
      ;;
    # one argument
    list|clean|mount|install|source|use|cache)
      if [[ $# -ne 2 ]]; then
        __hps_${1}_help
        echo "ERROR: hps ${1} requires one argument."
        return 1
      elif [[ "$2" == "help" ]]; then
        # subcommand help
        __hps_${1}_help
        return 0
      fi
      # outside container
      __hps_$1 ${@:2}
      return $?
      ;;
    # two or more arguments
    run)
      if [[ "$2" == "help" ]]; then
        __hps_${1}_help
        return 0
      elif [[ $# -lt 4 ]]; then
        __hps_${1}_help
        echo "ERROR: hps ${1} requires two arguments."
        return 1
      fi
      __hps_${1} ${@:2}
      return $?
      ;;
    *)
      # everything else goes into container
      # store current working directory
      local _pwd=$(pwd -P)/.
      # check if container will be able to see where we are
      if ! __hps_is_mounted $_pwd; then
        echo "You aren't in a directory mounted to the container!"
        return 1
      fi
      # run the arguments in the current directory inside the container
      __hps_run $_pwd $@
      return $?
      ;;
  esac
}

####################################################################################################
# DONE WITH NECESSARY PARTS
#   Everything below here is icing on the usability cake.
####################################################################################################

####################################################################################################
# Bash Tab Completion
#   This next section is focused on setting up the infrastucture for smart
#   tab completion with the hps command and its sub-commands.
####################################################################################################

####################################################################################################
# __hps_complete_directory
#   Some of our sub-commands take a directory as input.
#   In these cases, we can pretend to cd and use bash's internal
#   tab-complete functions.
#   
#   All this requires is for us to shift the COMP_WORDS array one to
#   the left so that the bash internal tab-complete functions don't
#   get distracted by our base command 'hps' at the front.
#
#   We could allow for the shift to be more than one if there is a deeper
#   tree of commands that need to be allowed in the future.
####################################################################################################
__hps_complete_directory() {
  local _num_words="1"
  COMP_WORDS=(${COMP_WORDS[@]:_num_words})
  COMP_CWORD=$((COMP_CWORD - _num_words))
  _cd
}

####################################################################################################
# __hps_complete_command
#   Tab-complete with a command used commonly inside the container
#
#   Current internal options are hard-coded. I wonder if there is a better way.
#   Any strings passed are also included as options.
#
#   Assumes current argument being tab completed is stored in
#   bash variable 'curr_word'.
####################################################################################################
__hps_complete_command() {
  # match current word (perhaps empty) to the list of options
  COMPREPLY=($(compgen -W "$@ cmake make python root rootbrowse" "$curr_word"))
}

####################################################################################################
# __hps_complete_bash_default
#   Restore the default tab-completion in bash that uses the readline function
#   Bash default tab completion just looks for filenames
####################################################################################################
__hps_complete_bash_default() {
  compopt -o default
  COMPREPLY=()
}

####################################################################################################
# __hps_dont_complete
#   Don't tab complete or suggest anything if user <tab>s
####################################################################################################
__hps_dont_complete() {
  COMPREPLY=()
}

####################################################################################################
# Modify the list of completion options on the command line
#   Helpful discussion of this procedure from a blog post
#   https://iridakos.com/programming/2018/03/01/bash-programmable-completion-tutorial
#
#   Helpful Stackoverflow answer
#   https://stackoverflow.com/a/19062943
#
#   COMP_WORDS - bash array of space-separated command line inputs including base command
#   COMP_CWORD - index of current word in argument list
#   COMPREPLY  - options available to user, if only one, auto completed
####################################################################################################
__hps_complete() {
  # disable readline filename completion
  compopt +o default

  local curr_word="${COMP_WORDS[$COMP_CWORD]}"

  if [[ "$COMP_CWORD" = "1" ]]; then
    # tab completing a main argument
    __hps_complete_command "help list clean config cache use run mount install source"
  elif [[ "$COMP_CWORD" = "2" ]]; then
    # tab complete a sub-argument,
    #   depends on the main argument
    case "${COMP_WORDS[1]}" in
      config|help|list|use)
        # no more arguments or can't tab-complete efficiently
        __hps_dont_complete
        ;;
      clean)
        # arguments from special set
        COMPREPLY=($(compgen -W "all container env" "$curr_word"))
        ;;
      run|mount|install|cache)
        #directories only after these commands
        __hps_complete_directory
        ;;
      *)
        # files like normal tab complete after everything else
        __hps_complete_bash_default
        ;;
    esac
  else
    # three or more arguments
    #   check base argument to see if we should continue
    case "${COMP_WORDS[1]}" in
      list|cache|clean|config|help|use|mount|install|source)
        # these commands shouldn't have tab complete for the third argument 
        #   (or shouldn't have the third argument at all)
        __hps_dont_complete
        ;;
      run)
        if [[ "$COMP_CWORD" = "3" ]]; then
          # third argument to run should be an inside-container command
          __hps_complete_command
        else
          # later arguments to run should be bash default
          __hps_complete_bash_default
        fi
        ;;
      *)
        # everything else has bash default (filenames)
        __hps_complete_bash_default
        ;;
    esac
  fi
}

# Tell bash the tab-complete options for our main function hps
complete -F __hps_complete hps

####################################################################################################
# If the default environment file exists, source it.
# Otherwise, trust that the user knows what they are doing.
####################################################################################################

if [[ -f $HOME/.hpsrc ]]; then
  hps source $HOME/.hpsrc
fi
