if status is-interactive
    fish_add_path --path --append $HOME/.local/bin $HOME/bin

    if command -q rustup
        set -l rust_path (rustup which rustc 2> /dev/null)
        if test -n "$rust_path"
            fish_add_path --path --append (path dirname "$rust_path")
        end
    end

    if command -q cargo
        fish_add_path --path --append $HOME/.cargo/bin
    end

    if command -q go
        fish_add_path --path --append "$(go env GOPATH)/bin"
    end

    if command -q pnpm
        set -gx PNPM_HOME $HOME/.local/share/pnpm
        fish_add_path --path --append $PNPM_HOME/bin
    end
end
