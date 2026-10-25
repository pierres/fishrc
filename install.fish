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
    set -l tide_version 7.2.0
    set -l tmp_dir (mktemp -d); or return 1
    set -l install_status 1
    if curl -fsSL "https://codeload.github.com/plttn/tide/tar.gz/v$tide_version" -o "$tmp_dir/tide.tar.gz"
        and tar -xzf "$tmp_dir/tide.tar.gz" -C "$tmp_dir"
        mkdir -p "$target_dir/.config/fish"
        and command cp -R "$tmp_dir/tide-$tide_version"/{completions,conf.d,functions} "$target_dir/.config/fish/"
        set install_status $status
    end
    command rm -rf -- "$tmp_dir"
    return $install_status
end

function main -a target_dir
    if test -z "$target_dir"
        set target_dir ~/
    end

    check_dependencies; or return 1

    echo "Installing fishrc to $target_dir..."

    mkdir -p "$target_dir/.config/fish/conf.d" "$target_dir/.config/fish/functions"; or return 1

    set -l tmp_dir (mktemp -d); or return 1
    git clone --depth 1 https://github.com/pierres/fishrc.git $tmp_dir
    and command cp -R "$tmp_dir"/{conf.d,functions} "$target_dir/.config/fish/"
    set -l install_status $status
    command rm -rf -- "$tmp_dir"
    test $install_status -eq 0; or return $install_status

    install_tide "$target_dir"; or return 1

    echo "Installation complete!"
    echo "Please restart your shell."
end

if not status --is-interactive
    main $argv
end
