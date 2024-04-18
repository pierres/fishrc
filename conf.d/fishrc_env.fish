if status is-interactive
    set -gx LESS -R

    if command -q xdg-open
        set -gx BROWSER xdg-open
    end

    if command -q nano
        set -gx EDITOR nano
        set -gx VISUAL nano
    end
end
