if status is-interactive
    if command -q less
        set -gx LESS -R
    end

    if command -q xdg-open
        set -gx BROWSER xdg-open
    end

    if command -q nano
        set -gx EDITOR nano
        set -gx VISUAL nano
    end
end
