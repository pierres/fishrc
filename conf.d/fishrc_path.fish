if status is-interactive
    if test -d $HOME/bin
        set -gxa PATH $HOME/bin
    end

    if command -q rustup; and rustup which rustc &>/dev/null
        set -gxa PATH (path dirname (rustup which rustc))
    end

    if command -q cargo
        set -gxa PATH $HOME/.cargo/bin
    end

    if command -q npm
        set -gx NPM_PACKAGES $HOME/.npm-packages
        set -gxa PATH $NPM_PACKAGES
    end

    if command -q pnpm
        set -gx PNPM_HOME $HOME/.local/share/pnpm
        set -gxa PATH $PNPM_HOME
    end
end
