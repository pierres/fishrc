function claude --wraps claude --description "Run Claude Code inside nono sandbox"
    if not command -q nono
        echo "nono not found, running claude without sandbox" >&2
        printf '\033]11;#1a0a0a\007'
        printf '\033]12;#cc3333\007'
        command claude $argv
        printf '\033]111\007'
        printf '\033]112\007'
        return
    end

    set -l tmpdir
    if test "$PWD" = "$HOME"
        set tmpdir (mktemp -d)
        echo "Running from \$HOME; using tmpdir $tmpdir (Landlock can't sandbox \$HOME with --allow-cwd)" >&2
        cd $tmpdir
    end

    set -l nono_args \
        --profile /etc/nono/profiles/claude.json \
        --allow-cwd \
        --silent

    # Ensure paths exist before nono resolves them (non-existent paths are skipped).
    # The built-in claude-code profile pre-creates these itself, but our custom
    # profile loads by path so that code path doesn't run.
    mkdir -p ~/.cache/claude ~/.cache/gh ~/.npm ~/.cache/claude-cli-nodejs
    touch ~/.claude.json.lock

    # ~/.claude.json — Claude Code writes atomically via temp files:
    #   <path>.tmp.<PID>.<timestamp> → rename to <path>
    # It resolves symlinks before computing the temp path, so redirecting
    # ~/.claude.json into ~/.claude/ keeps all writes inside the already
    # granted directory. Without this, Landlock would need write on ~/
    # to allow creation of unpredictable temp file names.
    set -l claude_json ~/.claude.json
    set -l claude_json_target ~/.claude/claude.json
    if not test -L $claude_json
        if test -f $claude_json
            mv $claude_json $claude_json_target
        else
            touch $claude_json_target
        end
        ln -s $claude_json_target $claude_json
    end

    # ~/.claude.lock — proper-lockfile creates this directory via mkdir/rmdir
    # for OAuth token refresh locking. Same symlink trick redirects into
    # ~/.claude/ so Landlock doesn't need MAKE_DIR+REMOVE_DIR on $HOME.
    set -l claude_lock ~/.claude.lock
    set -l claude_lock_target ~/.claude/.oauth-lock
    if not test -L $claude_lock
        rmdir $claude_lock 2>/dev/null; or rm -rf $claude_lock 2>/dev/null
        ln -sfn $claude_lock_target $claude_lock
    end
    rmdir $claude_lock_target 2>/dev/null

    # just: temp dir for recipe scripts (must exist before nono sees it)
    if command -q just
        set -l just_tmpdir /run/user/(id -u)/just
        mkdir -p $just_tmpdir
        set -a nono_args --allow $just_tmpdir
    end

    # go: dynamic paths from go env (not expressible in static profile)
    if command -q go
        set -a nono_args \
            --read (go env GOPATH)/bin \
            --allow (go env GOPATH)/pkg \
            --allow (go env GOCACHE)
    end

    # git-over-ssh: grant read to known_hosts and config only.
    # Private keys stay blocked. SSH agent socket works without rules.
    # Enable per machine via: set -g FISHRC_NONO_SSH true
    if test "$FISHRC_NONO_SSH" = true
        set -a nono_args \
            --override-deny ~/.ssh/known_hosts \
            --override-deny ~/.ssh/config \
            --read-file ~/.ssh/known_hosts \
            --read-file ~/.ssh/config
    end

    # per-machine overrides via ~/.config/fish/conf.d/local.fish:
    #   set -g FISHRC_NONO_EXTRA_ARGS --allow /extra/path
    if set -q FISHRC_NONO_EXTRA_ARGS
        set -a nono_args $FISHRC_NONO_EXTRA_ARGS
    end

    nono wrap $nono_args -- claude $argv

    if test -n "$tmpdir"
        cd $HOME
        rm -rf $tmpdir
    end
end
