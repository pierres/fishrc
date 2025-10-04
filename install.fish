#!/usr/bin/env fish

function check_dependencies
    for dep in curl tar mktemp git
        if not command -q $dep
            echo "Error: '$dep' is not installed. Please install it and try again." >&2
            return 1
        end
    end
    return 0
end

function install_tide -a target_dir
    if functions -q tide
        echo "tide is already installed."
        return 0
    end

    echo "Installing tide..."
    set -l tmp_dir (mktemp -d)
    mkdir -p "$target_dir/.config/fish/completions"
    curl -sL https://codeload.github.com/IlanCosman/tide/tar.gz/v6 | tar -xzC $tmp_dir
    command cp -R $tmp_dir/tide-6/completions/* "$target_dir/.config/fish/completions"
    command cp -R $tmp_dir/tide-6/conf.d/* "$target_dir/.config/fish/conf.d"
    command cp -R $tmp_dir/tide-6/functions/* "$target_dir/.config/fish/functions"
    rm -rf $tmp_dir
end

function main -a target_dir
    if test -z "$target_dir"
        set target_dir ~/
    end

    check_dependencies; or return 1

    echo "Installing fishrc to $target_dir..."

    mkdir -p "$target_dir/.config/fish/conf.d"
    mkdir -p "$target_dir/.config/fish/functions"

    set -l tmp_dir (mktemp -d)
    git clone --depth 1 https://github.com/pierres/fishrc.git $tmp_dir

    command cp -R $tmp_dir/conf.d/* "$target_dir/.config/fish/conf.d"
    command cp -R $tmp_dir/functions/* "$target_dir/.config/fish/functions"

    rm -rf $tmp_dir

    install_tide $target_dir

    echo "Installation complete!"
    echo "Please restart your shell."
end

if not status --is-interactive
    main $argv
end
