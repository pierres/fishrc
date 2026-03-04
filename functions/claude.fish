function claude --wraps claude --description "Run Claude Code inside nono sandbox"
    if not command -q nono
        echo "nono not found, running claude without sandbox" >&2
        command claude $argv
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
        --silent

    # gh: config + cache for GitHub CLI
    if command -q gh
        set -a nono_args \
            --read ~/.config/gh \
            --allow ~/.cache/gh
    end

    # node: npm/pnpm/yarn config and caches
    # npm/yarn workarounds tracked in https://github.com/always-further/nono/issues/233
    # npm: profile sets ~/.npm read-only, --allow can't upgrade it yet
    # (https://github.com/always-further/nono/pull/232). pnpm works fine.
    if command -q pnpm; or command -q npm; or command -q yarn
        set -a nono_args --read-file ~/.npmrc
    end
    if command -q yarn
        set -a nono_args \
            --read-file ~/.yarnrc \
            --allow ~/.cache/yarn
    end

    # bun: install cache at ~/.bun (uses registry.npmjs.org, already in allowlist)
    if command -q bun
        set -a nono_args --allow ~/.bun
    end

    # deno: module cache + jsr/deno.land registries
    if command -q deno
        set -a nono_args \
            --allow ~/.cache/deno \
            --proxy-allow jsr.io \
            --proxy-allow deno.land
    end

    # rust: cargo/rustup need write access to registry and toolchain paths
    # profile sets ~/.cargo and ~/.rustup read-only, same --allow upgrade bug
    # (https://github.com/always-further/nono/pull/232)
    # tracked in https://github.com/always-further/nono/issues/233

    # composer: global config + download cache + packagist host
    # tracked in https://github.com/always-further/nono/issues/233
    if command -q composer
        set -a nono_args \
            --read ~/.config/composer \
            --allow ~/.cache/composer \
            --proxy-allow repo.packagist.org
    end

    # go: module/sumdb cache, build cache + proxy/checksum hosts not in nono's allowlist
    # tracked in https://github.com/always-further/nono/issues/233
    if command -q go
        set -a nono_args \
            --allow (go env GOPATH)/pkg \
            --allow (go env GOCACHE) \
            --proxy-allow proxy.golang.org \
            --proxy-allow sum.golang.org
    end

    # nono's credential proxy injects an invalid GITHUB_TOKEN that overrides
    # the valid keyring token. Clear it so gh falls back to the keyring.
    # Only unset if user didn't set their own token before entering the sandbox.
    # https://github.com/always-further/nono/issues/234
    if set -q GITHUB_TOKEN
        nono run $nono_args -- claude $argv
    else
        nono run $nono_args -- env GITHUB_TOKEN= claude $argv
    end

    if test -n "$tmpdir"
        cd $HOME
        rm -rf $tmpdir
    end
end
