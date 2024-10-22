if status is-interactive
    if test -d $HOME/bin
        set -gxa PATH $HOME/bin
    end

    if command -q rustup
        set -l rust_path (rustup which rustc)
        if test -n "$rust_path"
            set -gxa PATH (path dirname "$rust_path")
        end
    end

    if command -q cargo
        set -gxa PATH $HOME/.cargo/bin
    end

    if command -q go
        set -gxa PATH "$(go env GOPATH)/bin"
    end

    if command -q pnpm
        set -gx PNPM_HOME $HOME/.local/share/pnpm
        set -gxa PATH $PNPM_HOME
    end
end
