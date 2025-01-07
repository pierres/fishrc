function update-all --description 'Update all packages using different package managers'
    function __update_package
        set -l label $argv[1]
        set -l cmd $argv[2]
        set -l dependencies $argv[3..-1]

        for dep in $dependencies
            if not command -q "$dep"
                return
            end
        end

        set_color --bold
        echo "$label"
        set_color normal
        eval "$cmd"
        echo -e "\n"
    end

    __update_package rust 'rustup update' rustup
    __update_package go 'gup update' gup
    __update_package pnpm 'pnpm upgrade -g --latest' pnpm
    __update_package flatpak 'sudo flatpak update && sudo flatpak remove --unused' flatpak sudo
    __update_package fwupdmgr 'sudo fwupdmgr refresh && sudo fwupdmgr update' fwupdmgr sudo
    __update_package pkgfile 'sudo pkgfile -u' pkgfile sudo
    __update_package pacman 'sudo pacman -Syu && begin set -l pkgs (pacman -Qqdt); test $status -eq 0; and test -n "$pkgs"; and sudo pacman -Rcsn $pkgs; or true; end' pacman sudo

    functions --erase __update_package
end
