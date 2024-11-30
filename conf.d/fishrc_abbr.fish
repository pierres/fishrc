if status is-interactive
    abbr lh ls -hAl
    abbr l ls -l

    if command -q just
        abbr jsut just
        abbr j just
    end

    if not abbr -q zed; and not command -q zed; and command -q zeditor
        abbr zed zeditor
    end
end
