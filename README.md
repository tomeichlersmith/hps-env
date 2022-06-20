# hps-env
Containerized development environment for HPS software.

<p align="center">
    <a href="http://perso.crans.org/besson/LICENSE.html" alt="GPLv3 license">
        <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
    </a>
    <a href="https://github.com/tomeichlersmith/hps-env/actions" alt="Actions">
        <img src="https://github.com/tomeichlersmith/hps-env/workflows/CI/badge.svg" />
    </a>
    <a href="https://hub.docker.com/r/tomeichlersmith/hps-env" alt="DockerHub">
        <img src="https://img.shields.io/github/v/release/tomeichlersmith/hps-env" />
    </a>
</p>

## Quick Start
If you do not intend to develop the containerized environment itself
and just wish to use it, all you need is the environment script.

1. Retrieve environment script from the ![latest release](https://img.shields.io/github/v/release/tomeichlersmith/hps-env)

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
