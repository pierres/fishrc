if status is-interactive
    abbr lh ls -hAl
    abbr l ls -l

    if not abbr -q hx; and not command -q hx; and command -q helix
        abbr hx helix
    end

    if command -q just
        abbr jsut just
    end

    if not abbr -q zed; and not command -q zed; and command -q zeditor
        abbr zed zeditor
    end
end
