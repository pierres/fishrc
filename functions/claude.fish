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

    # Migrate config from ~/.claude.json (symlink in $HOME) to
    # ~/.claude/.config.json (inside granted dir). This avoids needing
    # Landlock write on $HOME for temp files and locks.
    if test -L ~/.claude.json
        set -l target (readlink ~/.claude.json)
        if test -f "$target"
            mv "$target" ~/.claude/.config.json
        end
        rm ~/.claude.json
    else if test -f ~/.claude.json
        mv ~/.claude.json ~/.claude/.config.json
    end
    rm -f ~/.claude.json.lock
    # Clean up broken lock symlink from earlier workaround
    if test -L ~/.claude.lock
        rm ~/.claude.lock
    end

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
