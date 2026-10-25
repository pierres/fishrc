set -lx FISHRC_TEST_PATH_FILE (path resolve (status dirname)/../conf.d/fishrc_path.fish)
set -lx FISHRC_TEST_ROOT "$XDG_CONFIG_HOME/path fixture"
mkdir -p "$FISHRC_TEST_ROOT/bin" "$FISHRC_TEST_ROOT/rust/bin" "$FISHRC_TEST_ROOT/go/bin"; or exit 1
printf '%s\n' '#!/bin/sh
case "$0" in
    *rustup) printf "%s\n" "$FISHRC_TEST_ROOT/rust/bin/rustc" ;;
    *go) printf "%s\n" "$FISHRC_TEST_ROOT/go" ;;
    *cargo|*pnpm) exit 0 ;;
    *) exit 99 ;;
esac
' >"$FISHRC_TEST_ROOT/bin/rustup"
for tool in go cargo pnpm
    command cp "$FISHRC_TEST_ROOT/bin/rustup" "$FISHRC_TEST_ROOT/bin/$tool"; or exit 1
end
chmod +x "$FISHRC_TEST_ROOT"/bin/*; or exit 1
set -lx PATH "$FISHRC_TEST_ROOT/bin" $PATH

set -l initial_path $PATH
source "$FISHRC_TEST_PATH_FILE"
test (string join : -- $PATH) = (string join : -- $initial_path); or exit 1

set -l script "$FISHRC_TEST_ROOT/check.fish"
printf '%s\n' 'set -l initial_path $PATH
set -l initial_count (count $PATH)
source "$FISHRC_TEST_PATH_FILE"
set -l first_path $PATH
source "$FISHRC_TEST_PATH_FILE"
if test (string join : -- $PATH) != (string join : -- $first_path)
    echo "Repeated startup changed PATH again" >&2
    exit 1
end
test (string join : -- $PATH[1..$initial_count]) = (string join : -- $initial_path); or exit 1
set -l rust_index (contains -i -- "$FISHRC_TEST_ROOT/rust/bin" $PATH)
set -l go_index (contains -i -- "$FISHRC_TEST_ROOT/go/bin" $PATH)
test -n "$rust_index"; and test -n "$go_index"; or exit 1
test $rust_index -lt $go_index; or exit 1
' >"$script"
fish --no-config --interactive "$script"; or exit 1
exit 0
