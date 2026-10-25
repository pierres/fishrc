function _fishrc_reset_config
    echo 'Unexpected reset in a noninteractive shell' >&2
    exit 1
end

set -lx FISHRC_TEST_INIT_FILE (path resolve (status dirname)/../conf.d/fishrc_init.fish)
source "$FISHRC_TEST_INIT_FILE"

set -l script "$XDG_CONFIG_HOME/init.fish"
mkdir -p "$XDG_CONFIG_HOME"; or exit 1
printf '%s\n' 'function _fishrc_reset_config
    set -g reset_args $argv
end
set -g __fish_initialized 1
source "$FISHRC_TEST_INIT_FILE"
test "$reset_args" = --if-needed; or exit 1
' >"$script"

fish --no-config --interactive "$script"; or exit 1
exit 0
