source (status dirname)/../functions/_fishrc_check_command.fish
source (status dirname)/../functions/chromium-tmp.fish
source (status dirname)/../functions/firefox-tmp.fish

set -l fixture_dir "$XDG_CONFIG_HOME/browser tmp"
mkdir -p "$fixture_dir/bin" "$fixture_dir/tmp" "$fixture_dir/original-cache"; or exit 1
set -lx TMPDIR "$fixture_dir/tmp"
set -lx FISHRC_TEST_CACHE "$fixture_dir/cache-used"
set -lx FISHRC_TEST_ARGS "$fixture_dir/args"
set -lx FISHRC_TEST_LAUNCHES "$fixture_dir/launches"
set -lx FISHRC_TEST_BROWSER_STATUS 0
set -lx FISHRC_TEST_FAILED_TMPDIR "$fixture_dir/failed-allocation"
printf '%s\n' '#!/bin/sh
printf "%s\n" "$XDG_CACHE_HOME" > "$FISHRC_TEST_CACHE"
printf "%s\n" "$@" > "$FISHRC_TEST_ARGS"
printf "launched\n" >> "$FISHRC_TEST_LAUNCHES"
exit "$FISHRC_TEST_BROWSER_STATUS"
' >"$fixture_dir/bin/chromium"
command cp "$fixture_dir/bin/chromium" "$fixture_dir/bin/firefox"; or exit 1
chmod +x "$fixture_dir/bin/chromium" "$fixture_dir/bin/firefox"; or exit 1
set -lx PATH "$fixture_dir/bin" $PATH
set -gx XDG_CACHE_HOME "$fixture_dir/original-cache"

for browser in chromium-tmp firefox-tmp
    for browser_status in 0 47
        set FISHRC_TEST_BROWSER_STATUS $browser_status
        $browser 'https://example.test/a b'
        if test $status -ne $browser_status
            echo "$browser did not preserve the browser exit status" >&2
            exit 1
        end
        if test "$XDG_CACHE_HOME" != "$fixture_dir/original-cache"
            echo "$browser changed the caller's cache directory" >&2
            exit 1
        end
        set -l cache_used (string collect <"$FISHRC_TEST_CACHE")
        test "$cache_used" != "$XDG_CACHE_HOME"; or exit 1
        test -d (path dirname "$cache_used"); and exit 1
        string match -q -- 'https://example.test/a b' <"$FISHRC_TEST_ARGS"; or exit 1
    end
end

function mktemp
    echo "$FISHRC_TEST_FAILED_TMPDIR"
    return 43
end
printf '' >"$FISHRC_TEST_LAUNCHES"
for browser in chromium-tmp firefox-tmp
    $browser
    test $status -eq 43; or exit 1
end
test -s "$FISHRC_TEST_LAUNCHES"; and exit 1

function mktemp
    command mktemp $argv
end
function mkdir
    return 44
end
firefox-tmp
test $status -eq 44; or exit 1
test -s "$FISHRC_TEST_LAUNCHES"; and exit 1
set -l leftovers (find "$TMPDIR" -mindepth 1 -maxdepth 1)
test (count $leftovers) -eq 0; or exit 1
exit 0
