set -l failed 0

for test_file in (status dirname)/*.test.fish
    set -l test_dir (mktemp -d); or exit 1
    env XDG_CONFIG_HOME="$test_dir/config" \
        XDG_DATA_HOME="$test_dir/data" \
        XDG_CACHE_HOME="$test_dir/cache" \
        fish --no-config "$test_file"
    set -l test_status $status
    command rm -rf -- "$test_dir"

    if test $test_status -eq 0
        echo "PASS $test_file"
    else
        echo "FAIL $test_file" >&2
        set failed 1
    end
end

exit $failed
