function chromium-tmp --wraps chromium --description 'Launch a clean Chromium instance with a temporary profile'
    if not _fishrc_check_command chromium
        return 1
    end

    set -l tmpdir (mktemp -d -t chromium-tmp.XXXXXXXXXX); or return
    set -lx XDG_CACHE_HOME "$tmpdir/cache"

    chromium \
        --no-first-run \
        --disable-search-engine-choice-screen \
        --no-default-browser-check \
        --password-store=basic \
        --user-data-dir="$tmpdir/data" \
        $argv
    set -l browser_status $status

    rm -rf "$tmpdir"; or return
    return $browser_status
end
