# hps-env
Containerized development environment for HPS software.

<p align="center">
    <a href="http://perso.crans.org/besson/LICENSE.html" alt="GPLv3 license">
        <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
    </a>
    <a href="https://github.com/tomeichlersmith/hps-env/actions" alt="Actions">
        <img src="https://github.com/tomeichlersmith/hps-env/actions/workflows/ci.yml/badge.svg" />
    </a>
    <a href="https://hub.docker.com/r/tomeichlersmith/hps-env" alt="DockerHub">
        <img src="https://img.shields.io/github/v/release/tomeichlersmith/hps-env" />
    </a>
</p>

### Versions
This project using calendar versioning. I try to document the commits that are installed
in a specific release within those release notes, but I haven't found a way to do that
automatically yet so I sometimes forget.


## Quick Start
If you do not intend to develop the containerized environment itself
and just wish to use it, all you need is a container runner (and distrobox).

Below, I use the tag `2024.01.10` of the container as an example. This tag can
be replaced by any version of the image later that v1 or is calendar versioned
(which begun after v3.3.1).

### denv
The [denv](https://github.com/tomeichlersmith/denv) program requires a container 
runner (docker, podman, singularity, or apptainer) to be installed but then operates
the same for all of them.

Initialize a workspace to use this image as the base image for the development environment.
```
denv init tomeichlersmith/hps-env:2024.01.10
```
Then enter the environment
```
denv
```
Or simply run a command through the environment rather than your normal shell.
```
denv echo "Hello from inside the denv"
```

### docker or podman and distrobox
Create a distrobox using the image built from this repo on DockerHub.
```
distrobox create \
  --image tomeichlersmith/hps-env:2024.01.10 \
  --name hps-env \
  --home /full/path/to/hps
```
Here I changed the home directory of the distrobox to be the place where all
your HPS junk is. This is to avoid cluttering your real home directory with whatever
settings/caches/configs are written/read by things inside the box.

Then you can enter the environment.
```
distrobox enter hps-env
```
Now you are in a terminal inside the box with all the HPS dependencies installed.
It is Ubuntu 20.04 (CentOS7 was tried for v2 images) and is connected to your 
screen for graphical apps.
You have password-less `sudo` access to install anything else into the box you may
want. Changes to the box will not be persisted if the box is ever "stopped" but
generally the only time boxes are stopped are when a computer is rebooted.

### singularity or apptainer
There is ongoing work to include support for more container runtimes in distrobox
([Issue #511](https://github.com/89luca89/distrobox/issues/511)), so until that is 
completed the best option is using the `shell` subcommand.

Similar to above, it is a two-step procedure. First, we need to download the
image holding all of the HPS software dependencies.
```
singularity build hps-env-2024.01.10.sif docker://tomeichlersmith/hps-env:2024.01.10
```
_Side Note_: On SLAC's SDF, the temp directories are not allocated a lot of
space and singularity/apptainer needs a lot of space, so it is advised to 
define two environment variables to make sure that singularity has enough
space for building the layers.
```
# on SLAC's SDF only, before running the build command above
export TMPDIR=/scratch/$USER
export SINGULARITY_CACHEDIR=/scratch/$USER
```

Second, we enter the environment by opening a shell with singularity.
```
singularity run \
  --env "PS1=${PS1}" \
  --env "LS_COLORS=${LS_COLORS}" \
  --hostname hps-env.$(uname -n) \
  --home /full/path/to/hps \ # NO trailing slash
  hps-env-2024.01.10.sif \
  /bin/bash -i # make shell interactive
```

Make sure there isn't a trailing slash when you define the new home directory.
Leaving the trailing slash means that the prompt won't be able to effectively shorten
that home directory to the tilde character '~' like in a normal bash.

Ask for bash to be interactive `-i`. This will print some warnings since apptainer
doesn't have access the to group mappings that the host computer has, but it will
source the bash init files _in the new home directory_ allowing you to specialize the
container-internal shell as you see fit (e.g. updating the PATH variable or whatever)

This shell isn't as pretty or as well integrated with the host as the one produced by distrobox;
however, it is still functional. (Note: `apptainer` is the new name for `singularity` and has
the same CLI - if your system only has the older version named `singularity` simply use the same
subcommands but with `singularity`).

Unlike the docker-hosted container above, this one isn't writable, so you will not be able to
installl anything else into the box. This means you will probably want two side-by-side terminals:
one inside the box for compiling and running the software and one outside the box for using other
tools that aren't in the container (like a text editor).

## Usage Tips
Below are some helpful tips for making your workflow more streamlined when using this container.

### Local Installation
Since your home directory within the container is the directory with all your HPS stuff in it,
I would suggest having your install location for any HPS packages you are developing to be 
`~/.local`. This is a standard Linux install package for users and can easily be inlucded in 
the `*PATH*` environment variables so the installed libraries and executables are easily accessible.

### Specialize the bashrc
Again, since your home directory in the container is separate from your regular home directory,
you can add a bunch of HPS-specific things to the `.bashrc` file that is located in the HPS
home directory. I would suggest making sure the `*PATH*` variables include `${HOME}/.local`,
but don't hesitate to take it further and include HPS-specific shell functions and aliases
to do tasks that you do frequently.
