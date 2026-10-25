source (status dirname)/../functions/git-branch-clean.fish

function _fishrc_check_command
    return 0
end

function git
    switch "$argv"
        case status 'remote prune origin' 'gc --aggressive'
            return 0
        case 'branch -vv'
            echo '  gone-branch abc1234 [origin/gone-branch: gone] subject'
        case 'branch --merged'
            printf '%s\n' '* current' '  master' '  main' '  dev' \
                '  feature/domain-model' '  feature/development-tools' \
                '  feature/fix' '+ linked-worktree' '  gone-branch'
        case 'branch -d *'
            set -ga test_deletions $argv[3]
        case '*'
            echo "Unexpected Git command: $argv" >&2
            return 1
    end
end

set -g test_deletions
git-branch-clean; or exit 1
set -l expected gone-branch feature/domain-model feature/development-tools feature/fix
if test (string join ' ' $test_deletions) != (string join ' ' $expected)
    echo "Unexpected branch deletion attempts: $test_deletions" >&2
    exit 1
end
exit 0
