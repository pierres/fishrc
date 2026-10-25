source (status dirname)/../functions/_fishrc_reset_config.fish

function assert_equal -a expected actual
    if test "$expected" != "$actual"
        echo "Expected '$expected', got '$actual'" >&2
        exit 1
    end
end

function fish_config
    return $theme_status
end

function yes
    echo y
end

function tide
    set -ga tide_calls $argv[1]
    switch $argv[1]
        case --version
            echo "tide, version $test_tide_version"
        case configure
            if contains -- --transient=No $argv
                echo 'Tide 7 does not accept --transient' >&2
                set -g configure_result 2
                return 2
            end
            set -g configure_result $configure_status
            return $configure_result
        case reload
            return $reload_status
        case '*'
            echo "Unexpected Tide command: $argv" >&2
            return 1
    end
end

set -g test_tide_version 7.2.0
set -g theme_status 0
set -g configure_status 0
set -g reload_status 0
_fishrc_reset_config --if-needed >/dev/null
assert_equal 0 $status
assert_equal 0 $configure_result
assert_equal 'configure reload' (string join -- ' ' $tide_calls)
assert_equal 1 "$_fishrc_config_revision"

set -g tide_calls
_fishrc_reset_config --if-needed >/dev/null
assert_equal 0 $status
assert_equal 0 (count $tide_calls)

set -g tide_calls
_fishrc_reset_config >/dev/null
assert_equal 0 $status
assert_equal 'configure reload' (string join -- ' ' $tide_calls)

set -g test_tide_version 8.0.0
set -g tide_calls
_fishrc_reset_config --if-needed >/dev/null
assert_equal 0 $status
assert_equal 0 (count $tide_calls)
assert_equal 1 "$_fishrc_config_revision"

set -U _fishrc_config_revision 0
set -g tide_calls
_fishrc_reset_config --if-needed >/dev/null
assert_equal 0 $status
assert_equal 'configure reload' (string join -- ' ' $tide_calls)
assert_equal 1 "$_fishrc_config_revision"

set -g configure_status 42
set -g tide_calls
_fishrc_reset_config >/dev/null
assert_equal 42 $status
assert_equal configure (string join -- ' ' $tide_calls)

set -g configure_status 0
set -g reload_status 43
set -g tide_calls
_fishrc_reset_config >/dev/null
assert_equal 43 $status
assert_equal 'configure reload' (string join -- ' ' $tide_calls)

set -g reload_status 0
set -g theme_status 45
set -g tide_calls
_fishrc_reset_config >/dev/null
assert_equal 45 $status
assert_equal 0 (count $tide_calls)
exit 0
