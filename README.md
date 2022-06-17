# hps-env
Containerized development environment for HPS software.

## Quick Start
If you do not intend to develop the containerized environment itself
and just wish to use it, all you need is the environment script.

```bash
wget https://raw.githubusercontent.com/tomeichlersmith/hps-env/main/env.sh
source env.sh
hps mount /path/to/sw/parent/dir/
hps install /some/dir/to/install/sw/
hps use latest
```

