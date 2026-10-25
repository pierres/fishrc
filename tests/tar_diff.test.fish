source (status dirname)/../functions/tar-diff.fish

function _fishrc_check_command
    return 0
end

function bsdtar
    echo "$argv[2]" >>"$FISHRC_TEST_LOG"
    if test "$argv[2]" = "$FISHRC_TEST_FAIL_ARCHIVE"
        return 42
    end
    printf '%s\n' "$argv[2]" >"$argv[-1]/file"
end

set -l fixture_dir "$XDG_CONFIG_HOME/tar diff"
mkdir -p "$fixture_dir/tmp"; or exit 1
set -lx TMPDIR "$fixture_dir/tmp"
set -lx FISHRC_TEST_LOG "$fixture_dir/extractions"
set -lx FISHRC_TEST_FAIL_ARCHIVE ''
set -l first "$fixture_dir/first archive.tar"
set -l second "$fixture_dir/second archive.tar"
printf '%s\n' archive >"$first"
printf '%s\n' archive >"$second"
cd "$fixture_dir"; or exit 1

for scenario in first-failure second-failure success
    set -l expected_status 0
    set -l expected_extractions 2
    switch $scenario
        case first-failure
            set FISHRC_TEST_FAIL_ARCHIVE "$first"
            set expected_status 42
            set expected_extractions 1
        case second-failure
            set FISHRC_TEST_FAIL_ARCHIVE "$second"
            set expected_status 42
        case success
            set FISHRC_TEST_FAIL_ARCHIVE ''
    end
    printf '' >"$FISHRC_TEST_LOG"
    tar-diff "$first" "$second"
    if test $status -ne $expected_status
        echo "Unexpected exit status for $scenario" >&2
        exit 1
    end
    set -l extractions (string match -r '.+' <"$FISHRC_TEST_LOG")
    test (count $extractions) -eq $expected_extractions; or exit 1
    set -l leftovers (find "$TMPDIR" -mindepth 1 -maxdepth 1)
    test (count $leftovers) -eq 0; or exit 1

    if test "$scenario" = success
        test -s 'first archive.tar-second archive.tar.patch'; or exit 1
    else
        test -e 'first archive.tar-second archive.tar.patch'; and exit 1
    end
end

sleep 5 &
set -l unrelated_pid $last_pid
tar-diff "$first" "$second"
set -l compare_status $status
command kill -0 $unrelated_pid 2>/dev/null
set -l unrelated_status $status
command kill $unrelated_pid 2>/dev/null
builtin wait $unrelated_pid
if test $compare_status -ne 0; or test $unrelated_status -ne 0
    echo 'Archive comparison failed or waited for an unrelated job' >&2
    exit 1
end

function mktemp
    return 43
end
function mkdir
    echo 'Unexpected mkdir after mktemp failure' >&2
    return 44
end
tar-diff "$first" "$second"
test $status -eq 43; or exit 1
exit 0
