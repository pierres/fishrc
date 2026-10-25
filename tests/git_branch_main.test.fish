source (status dirname)/../functions/_fishrc_check_command.fish
source (status dirname)/../functions/git-branch-main.fish

set -l fixture_dir "$XDG_CONFIG_HOME/git-branch-main"
mkdir -p "$fixture_dir/git-bin" "$fixture_dir/gh-bin"; or exit 1
set -lx FISHRC_TEST_LOG "$fixture_dir/calls"
set -lx FISHRC_TEST_FAILURE ''

printf '%s\n' '#!/bin/sh
printf "git %s\n" "$*" >> "$FISHRC_TEST_LOG"
case "$*" in
    "branch -a -r") printf "  origin/master\n" ;;
    "branch -m master main") [ "$FISHRC_TEST_FAILURE" != rename ] || exit 42 ;;
    "push -u origin main") [ "$FISHRC_TEST_FAILURE" != push ] || exit 42 ;;
    "push origin --delete master") [ "$FISHRC_TEST_FAILURE" != delete ] || exit 42 ;;
    "remote -v") printf "origin git@github.com:example/repo.git (fetch)\n" ;;
    *) exit 99 ;;
esac
' >"$fixture_dir/git-bin/git"

printf '%s\n' '#!/bin/sh
printf "gh %s\n" "$*" >> "$FISHRC_TEST_LOG"
case "$1 $2" in
    "repo view")
        [ "$FISHRC_TEST_FAILURE" != query ] || exit 42
        printf "master\n"
        ;;
    "repo edit") [ "$FISHRC_TEST_FAILURE" != edit ] || exit 42 ;;
    *) exit 99 ;;
esac
' >"$fixture_dir/gh-bin/gh"
chmod +x "$fixture_dir/git-bin/git" "$fixture_dir/gh-bin/gh"; or exit 1

set -lx PATH "$fixture_dir/git-bin" "$fixture_dir/gh-bin"
set -l failure_stages rename push query edit delete
set -l expected_calls 3 4 5 6 7
for case_index in 1 2 3 4 5
    set FISHRC_TEST_FAILURE $failure_stages[$case_index]
    printf '' >"$FISHRC_TEST_LOG"
    git-branch-main 2>"$fixture_dir/errors"
    if test $status -ne 42
        echo "Did not propagate the $FISHRC_TEST_FAILURE failure" >&2
        exit 1
    end
    set -l calls (string match -r '.+' <"$FISHRC_TEST_LOG")
    if test (count $calls) -ne $expected_calls[$case_index]
        echo "Unexpected operations after the $FISHRC_TEST_FAILURE failure" >&2
        exit 1
    end
end

set FISHRC_TEST_FAILURE ''
printf '' >"$FISHRC_TEST_LOG"
git-branch-main; or exit 1
set -l calls (string match -r '.+' <"$FISHRC_TEST_LOG")
test (count $calls) -eq 7; or exit 1
test "$calls[-1]" = 'git push origin --delete master'; or exit 1

set -lx PATH "$fixture_dir/git-bin"
printf '' >"$FISHRC_TEST_LOG"
git-branch-main 2>"$fixture_dir/errors"
test $status -eq 1; or exit 1
if string match -qr '^git push origin --delete master$' <"$FISHRC_TEST_LOG"
    echo 'Attempted to delete master without gh available' >&2
    exit 1
end
exit 0
