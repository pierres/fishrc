function claude --wraps claude --description "Run Claude Code inside nono sandbox"
    if not command -q nono
        echo "nono not found, running claude without sandbox" >&2
        # Red background + cursor to warn: unsandboxed
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

    # base sandbox config
    set -l nono_args \
        --profile claude-code \
        --allow-cwd \
        --silent \
        --no-rollback \
        --net-allow

    # gh: config + cache for GitHub CLI
    if command -q gh
        mkdir -p ~/.cache/gh
        set -a nono_args \
            --read ~/.config/gh \
            --allow ~/.cache/gh
    end

    # node: npm/pnpm/yarn config and caches
    if command -q pnpm; or command -q npm; or command -q yarn
        touch ~/.npmrc
        set -a nono_args --read-file ~/.npmrc
    end
    if command -q yarn
        set -a nono_args \
            --read-file ~/.yarnrc \
            --allow ~/.cache/yarn
    end

    # bun: install cache at ~/.bun
    if command -q bun
        set -a nono_args --allow ~/.bun
    end

    # deno: module cache
    if command -q deno
        set -a nono_args --allow ~/.cache/deno
    end

    # composer: global config + download cache
    if command -q composer
        set -a nono_args \
            --read ~/.config/composer \
            --allow ~/.cache/composer
    end

    # just: temp dir for recipe scripts (must exist before nono sees it)
    if command -q just
        set -l just_tmpdir /run/user/(id -u)/just
        mkdir -p $just_tmpdir
        set -a nono_args --allow $just_tmpdir
    end

    # go: module/sumdb cache, build cache
    if command -q go
        set -a nono_args \
            --allow (go env GOPATH)/pkg \
            --allow (go env GOCACHE) \
            --allow ~/.cache/golangci-lint
    end

    # per-machine overrides via ~/.config/fish/conf.d/local.fish:
    #   set -g FISHRC_NONO_EXTRA_ARGS --allow /extra/path
    if set -q FISHRC_NONO_EXTRA_ARGS
        set -a nono_args $FISHRC_NONO_EXTRA_ARGS
    end

    nono run $nono_args -- claude $argv

    if test -n "$tmpdir"
        cd $HOME
        rm -rf $tmpdir
    end
end
