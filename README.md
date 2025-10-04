# Fishrc
This project contains my preferred Fish configuration. It tries to be system independent. It will initialize a new Fish Shell using the ``_fishrc_reset_config`` command. **Note**: this will remove any universal variables you might have defined.

## Installation
This configuration can be installed using the `justfile` included in this repository. Run the following command to install the configuration files to the `/etc/fish` directory:
```sh
just install target /
```

Alternatively, you can install the configuration to your home directory by running the following command:

```sh
curl -sSL https://raw.githubusercontent.com/pierres/fishrc/main/install.fish | fish
```

## Functions
This configuration comes with a set of custom functions to streamline common tasks:

| Function | Description |
|---|---|
| `_fishrc_reset_config` | Reset Fish configuration and reconfigure fishrc |
| `chromium-tmp` | Launch a clean Chromium instance with a temporary profile |
| `create-cd-image` | Create cue/bin image file of a CD-ROM |
| `docker-clean` | Remove all Docker containers, networks and volumes |
| `firefox-tmp` | Launch a clean Firefox instance with a temporary profile |
| `git-branch-clean` | Remove branches that no longer exist remotely or are merged locally |
| `git-branch-main` | Rename the default Git branch from master to main |
| `go-clean` | Clean all Go caches |
| `tar-diff` | Create a patch file containing the differences between the content of two tar archives |
| `update-all` | Update all packages using different package managers |

## Dependencies
This configuration relies on the following external commands:

### Core
* [fish](https://fishshell.com/)
* [tide](https://github.com/IlanCosman/tide)

### Functions
* **`create-cd-image`**: `cdrdao`, `toc2cue`
* **`docker-clean`**: `docker`
* **`git-branch-main`**: `gh`
* **`go-clean`**: `go`
* **`tar-diff`**: `bsdtar`, `diff`
* **`update-all`**: `flatpak`, `fwupdmgr`, `gup`, `pacman`, `pkgfile`, `pnpm`, `rustup`
