if status is-interactive
    abbr lh ls -hAl
    abbr l ls -l

	set -gx LESS -R

    if command -q helix
        abbr hx helix
    end

    if command -q just
        abbr jsut just
    end
end
