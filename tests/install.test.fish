function assert_equal -a expected actual
    if test "$expected" != "$actual"
        echo "Expected '$expected', got '$actual'" >&2
        exit 1
    end
end

set -l installer (path resolve (status dirname)/../install.fish)
set -l fixture_dir "$XDG_CONFIG_HOME/installer"
set -l release_dir "$fixture_dir/release/tide-7.2.0"
mkdir -p "$fixture_dir/bin" "$fixture_dir/functions" \
    "$release_dir/completions" "$release_dir/conf.d" \
    "$release_dir/functions/tide/configure/configs"; or exit 1
printf '%s\n' 'Tide completion' >"$release_dir/completions/tide.fish"
printf '%s\n' 'Tide initialization' >"$release_dir/conf.d/_tide_init.fish"
printf '%s\n' 'Tide function' >"$release_dir/functions/tide.fish"
printf '%s\n' 'Tide config' >"$release_dir/functions/tide/configure/configs/rainbow.fish"
tar -czf "$fixture_dir/tide.tar.gz" -C "$fixture_dir/release" tide-7.2.0; or exit 1

printf '%s\n' '#!/bin/sh
if [ "$FISHRC_TEST_FAILURE" = clone ]; then exit 1; fi
for destination; do :; done
cp -R "$FISHRC_TEST_SOURCE/conf.d" "$FISHRC_TEST_SOURCE/functions" "$destination/"
' >"$fixture_dir/bin/git"

printf '%s\n' '#!/bin/sh
while [ "$#" -gt 0 ]; do
    case "$1" in
        -o|--output) shift; destination=$1 ;;
        https://*) url=$1 ;;
    esac
    shift
done
[ "$url" = https://codeload.github.com/plttn/tide/tar.gz/v7.2.0 ] || exit 1
case "$FISHRC_TEST_FAILURE" in
    download) exit 22 ;;
    archive) printf "invalid archive" > "$destination" ;;
    *) cp "$FISHRC_TEST_ARCHIVE" "$destination" ;;
esac
' >"$fixture_dir/bin/curl"
chmod +x "$fixture_dir/bin/git" "$fixture_dir/bin/curl"; or exit 1

set -lx PATH "$fixture_dir/bin" $PATH
set -lx fish_function_path "$fixture_dir/functions"
set -lx FISHRC_TEST_SOURCE (path dirname "$installer")
set -lx FISHRC_TEST_ARCHIVE "$fixture_dir/tide.tar.gz"
set -lx FISHRC_TEST_FAILURE ''

set -l target "$fixture_dir/target success"
set -l output (fish --no-config "$installer" "$target" 2>"$fixture_dir/errors")
assert_equal 0 $status
contains -- 'Installation complete!' $output; or exit 1
for installed_file in conf.d/fishrc_init.fish functions/_fishrc_reset_config.fish \
    completions/tide.fish conf.d/_tide_init.fish functions/tide.fish \
    functions/tide/configure/configs/rainbow.fish
    if not test -f "$target/.config/fish/$installed_file"
        echo "Missing installed file: $installed_file" >&2
        exit 1
    end
end

for failure in clone download archive copy mkdir
    set FISHRC_TEST_FAILURE $failure
    set -l target "$fixture_dir/target-$failure"
    switch $failure
        case copy
            mkdir -p "$target/.config/fish"; or exit 1
            touch "$target/.config/fish/completions"; or exit 1
        case mkdir
            touch "$target"; or exit 1
    end
    set -l output (fish --no-config "$installer" "$target" 2>"$fixture_dir/errors")
    if test $status -eq 0; or contains -- 'Installation complete!' $output
        echo "Installation reported success after $failure failure" >&2
        exit 1
    end
    if test "$failure" != copy
        test -f "$target/.config/fish/functions/tide.fish"; and exit 1
    end
end

printf '%s\n' 'function tide; end' >"$fixture_dir/functions/tide.fish"
set FISHRC_TEST_FAILURE download
set -l target "$fixture_dir/target-existing-tide"
set -l output (fish --no-config "$installer" "$target" 2>"$fixture_dir/errors")
assert_equal 0 $status
contains -- 'tide is already installed.' $output; or exit 1
test -f "$target/.config/fish/functions/tide.fish"; and exit 1
exit 0
