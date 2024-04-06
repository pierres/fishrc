if status is-interactive
    set -gx LESS -R

    if command -q chromium
        set -gx BROWSER chromium
    else if command -q firefox
        set -gx BROWSER firefox
    end

    if command -q nano
        set -gx EDITOR nano
        set -gx VISUAL nano
    end
end
