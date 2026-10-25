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

The home installer installs [Tide 7.2.0](https://github.com/plttn/tide/releases/tag/v7.2.0)
if Tide is not already available. It leaves existing Tide installations in place.

## Configuration updates
Interactive startup runs `_fishrc_reset_config --if-needed`. A universal
`_fishrc_config_revision` records the last applied fishrc revision. A revision
change reapplies the defaults, clearing universal variables as described above.
The revision is saved after success; failed setup is retried next startup.
Run `_fishrc_reset_config` without arguments to force a reset.

Increment `config_revision` in `functions/_fishrc_reset_config.fish` whenever
changes to the defaults should trigger a reset. Fish and Tide version changes
do not trigger resets; review major updates and bump the revision if needed.

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
* [tide](https://github.com/plttn/tide)

### Functions
* **`create-cd-image`**: `cdrdao`, `toc2cue`
* **`docker-clean`**: `docker`
* **`git-branch-main`**: `gh`
* **`go-clean`**: `go`
* **`tar-diff`**: `bsdtar`, `diff`
* **`update-all`**: `flatpak`, `fwupdmgr`, `gup`, `pacman`, `pkgfile`, `pnpm`, `rustup`
