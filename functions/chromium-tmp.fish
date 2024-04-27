function chromium-tmp --wraps chromium --description 'Launch a clean Chromium instance with a temporary profile'
    if not command -q chromium
        echo 'chromium command not found'
        fish_command_not_found chromium
        return 1
    end

    set -l tmpdir (mktemp -d -t chromium-tmp.XXXXXXXXXX)
    set -x XDG_CACHE_HOME "$tmpdir/cache"

    trap "rm -rf '$tmpdir'" EXIT INT

    chromium \
        --no-first-run \
        --disable-search-engine-choice-screen \
        --no-default-browser-check \
        --password-store=basic \
        --user-data-dir="$tmpdir/data" \
        $argv

    rm -rf "$tmpdir"
end
