function update-all --description 'Update all packages using different package managers'
    function update_package
        set -l cmd $argv[1]
        set -l dependencies $argv[2..-1]

        for dep in $dependencies
            if not command -q "$dep"
                return
            end
        end

        set_color --bold
        echo "$cmd"
        set_color normal
        eval "$cmd"
        echo -e "\n"
    end

    update_package 'rustup update' rustup
    update_package 'gup update' gup
    update_package 'pnpm upgrade -g --latest' pnpm
    update_package 'npm update -g' npm
    update_package 'flatpak update' flatpak
    update_package 'sudo fwupdmgr refresh && sudo fwupdmgr update' fwupdmgr sudo
    update_package 'sudo pkgfile -u' pkgfile sudo
    update_package 'sudo pacman -Syu' pacman sudo
end
