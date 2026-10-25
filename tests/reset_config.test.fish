source (status dirname)/../functions/_fishrc_reset_config.fish

function assert_equal -a expected actual
    if test "$expected" != "$actual"
        echo "Expected '$expected', got '$actual'" >&2
        exit 1
    end
end

function fish_config
    return 0
end

function yes
    echo y
end

function fish_prompt
    set -g prompt_called true
end

function tide
    set -ga tide_calls $argv[1]
    switch $argv[1]
        case configure
            if contains -- --transient=No $argv
                echo 'Tide 7 does not accept --transient' >&2
                set -g configure_result 2
                return 2
            end
            set -g configure_result $configure_status
            return $configure_result
        case reload
            return 0
        case '*'
            echo "Unexpected Tide command: $argv" >&2
            return 1
    end
end

set -g configure_status 0
set -g prompt_called false
_fishrc_reset_config >/dev/null
assert_equal 0 $status
assert_equal 0 $configure_result
assert_equal 'configure reload' (string join ' ' $tide_calls)
assert_equal true $prompt_called

set -g configure_status 42
set -g tide_calls
set -g prompt_called false
_fishrc_reset_config >/dev/null
assert_equal 42 $status
assert_equal configure (string join ' ' $tide_calls)
assert_equal false $prompt_called
exit 0
