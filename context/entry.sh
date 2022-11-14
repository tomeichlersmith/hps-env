#!/bin/bash 

set -e

###############################################################################
# Entry point for the hep-env container
#   The basic idea is that we want to go into the container,
#   setup the working environment, and then
#   run whatever executable the user wants.
#
#   A lot of executables require us to be in a specific location,
#   so the first argument is required to be a directory we can go to.
#   The rest of the arguments are passed to `eval` to be run as one command.
#
#   All of the aliases that are defined in the hep-env script will
#   have $(pwd) be the first argument to the entrypoint.
#   This means, before executing anything on the container,
#   we will go to the mounted location that the user is running from.
#
#   Assumptions:
#   - Any initialization scripts for external dependencies need to be
#     symlinked into the directory ${__hep_env_script_d__} after being
#     installed in the container image.
###############################################################################

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
