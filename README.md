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

### Note
We are transitioning to a more integrated design for the environment container
based on [distrobox](https://github.com/89luca89/distrobox). If you are using `docker`
or `podman` on your computer, install distrobox and use a container after v0.11.0.

The environment script is lagging behind and may not support the latest container.

## Quick Start
If you do not intend to develop the containerized environment itself
and just wish to use it, all you need is the environment script (or distrobox).

### distrobox
Create a distrobox using the image built from this repo on DockerHub.
```
distrobox create -i tomeichlersmith/hps-env:edge -n hps-env -H /full/path/to/hps
```
Here I changed the home directory of the distrobox to be the place where all
your HPS junk is. This is to avoid cluttering your real home directory with whatever
settings/caches/configs are written/read by things inside the box.

Then you can enter the environment.
```
distrobox enter hps-env
```
Now you are in a terminal inside the box with all the HPS dependencies installed.
It is Ubuntu 20.04 and is connected to your screen for graphical apps.
You have password-less `sudo` access to install anything else into the box you may
want. Changes to the box will not be persisted if the box is ever "stopped" but
generally the only time boxes are stopped are when a computer is rebooted.

### env.sh

1. Retrieve environment script from [latest release](https://github.com/tomeichlersmith/hps-env/releases)

2. Setup environment
```bash
source env.sh
hps mount /path/to/sw/parent/dir/
hps install /some/dir/to/install/sw/
hps use latest
```

3. (optional) Solidify Setup
The last three commands in step (2) can be tedious, so you can provide a "RC" file
to the environment script to use. First write the environment configuration you
want to use.
```
# file: hpsrc
mount /path/to/dir/to/mount
install /path/to/install/sw
use latest
```
Then call the environment script with this file.
```bash
source env.sh hpsrc
```
The environment script also checks at `~/.hpsrc` and `${HPSRC}` if you want to use
those other options instead.
