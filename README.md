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
or `podman` on your computer, install distrobox and use a container _after_ v0.11.0.

The environment script is lagging behind and may not support the latest container.

## Quick Start
If you do not intend to develop the containerized environment itself
and just wish to use it, all you need is a container runner (and distrobox).

### docker and distrobox
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

### singularity and apptainer
There is ongoing work to include support for more container runtimes in distrobox
([Issue #511](https://github.com/89luca89/distrobox/issues/511)), so until that is 
completed the best option is using the `shell` subcommand.

```
apptainer build hps-env-tag.sif docker://tomeichlersmith/hps-env:tag
apptainer shell -H /full/path/to/hps hps-env-tag.sif
```

This shell isn't as pretty as well integrated with the host as the one produced by distrobox;
however, it is still functional.
