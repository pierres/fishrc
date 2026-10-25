set -l fixture_dir "$XDG_CONFIG_HOME/check"
set -l repo_dir (path resolve (status dirname)/..)
mkdir -p "$fixture_dir"; or exit 1
command cp "$repo_dir/justfile" "$fixture_dir/justfile"; or exit 1
printf '%s\n' 'echo first' >"$fixture_dir/a.fish"
printf '%s\n' 'echo second' >"$fixture_dir/b with spaces.fish"

just --working-directory "$fixture_dir" --justfile "$fixture_dir/justfile" check >"$fixture_dir/output" 2>&1
if test $status -ne 0
    cat "$fixture_dir/output" >&2
    exit 1
end

set -l check_files (find "$fixture_dir" -type f -name '*.fish')
printf '%s\n' 'if true' >"$check_files[-1]"
just --working-directory "$fixture_dir" --justfile "$fixture_dir/justfile" check >"$fixture_dir/output" 2>&1
if test $status -eq 0
    echo 'Syntax checking accepted an invalid file after the first file' >&2
    exit 1
end
exit 0
