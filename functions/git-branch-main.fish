function git-branch-main --description='Rename the default Git branch from master to main'
    if not command -q git
        echo 'Git is not installed' >&2
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

    if command -q gh; and string match -q master (gh repo view --jq '.defaultBranchRef.name' --json 'defaultBranchRef' 2>/dev/null)
        gh repo edit --default-branch main
    end

    git push origin --delete master
end
