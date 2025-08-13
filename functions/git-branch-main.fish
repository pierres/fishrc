function git-branch-main --description 'Rename the default Git branch from master to main'
    if not _fishrc_check_command git
        return 1
    end

    if not string match -qr '^\s*origin/master$' (git branch -a -r)
        echo 'Repository has no master branch' >&2
        return 1
    end

    if string match -qr '^\s*origin/main$' (git branch -a -r)
        echo 'Repository already has a main branch' >&2
        return 1
    end

    git branch -m master main

    git push -u origin main

    if command -q gh
        if string match -q master (gh repo view --jq '.defaultBranchRef.name' --json 'defaultBranchRef' 2>/dev/null)
            gh repo edit --default-branch main
        end
    else if git remote -v | string match -q 'github.com'
        echo "Warning: 'gh' command not found, please change the default branch on GitHub manually." >&2
    end

    git push origin --delete master
end
