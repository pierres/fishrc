source (status dirname)/../functions/create-cd-image.fish

function _fishrc_check_command
    return 0
end

function cdrdao
    set -ga tool_calls read
    printf '%s\n' 'TOC metadata' >"$argv[-1]"
    return $read_status
end

function toc2cue
    set -ga tool_calls convert
    printf '%s\n' 'CUE metadata' >"$argv[2]"
    return $convert_status
end

mkdir -p "$XDG_CONFIG_HOME"; or exit 1
for scenario in read-failure conversion-failure success
    set -g read_status 0
    set -g convert_status 0
    set -g tool_calls
    set -l expected_status 0
    set -l name "$XDG_CONFIG_HOME/$scenario image"
    switch $scenario
        case read-failure
            set -g read_status 42
            set expected_status 42
        case conversion-failure
            set -g convert_status 43
            set expected_status 43
    end

    create-cd-image "$name"
    if test $status -ne $expected_status
        echo "Unexpected exit status for $scenario" >&2
        exit 1
    end

    if test "$scenario" = success
        test -f "$name.cue"; or exit 1
        test -e "$name.toc"; and exit 1
    else
        if not test -f "$name.toc"
            echo "TOC metadata was removed after $scenario" >&2
            exit 1
        end
    end

    if test "$scenario" = read-failure
        test "$tool_calls" = read; or exit 1
    else
        test "$tool_calls" = 'read convert'; or exit 1
    end
end
exit 0
