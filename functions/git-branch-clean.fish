function git-branch-clean --description 'Remove branches that no longer exist remotely or are merged locally'
    if not _fishrc_check_command git
        return 1
    end

    if not git status &>/dev/null
        echo "No valid git repository found" >&2
        return 1
    end

    git remote prune origin

    set -l deleted_branches
    for b in \
        (git branch -vv | string match -gr '^\s*(\S+)\s+.*: gone\].*' | string trim) \
        (git branch --merged | string match -rv '(^\\*|master|main|dev)' | string trim)
        if not contains $b $deleted_branches
            git branch -d $b
            set -a deleted_branches $b
        end
    end

    git gc --aggressive
end
