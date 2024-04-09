if status is-interactive; and not set -q __fish_initialized
    function fishrc_install --on-event fish_prompt
        if not set -q __fish_initialized
            fishrc_reset_config
        end
    end
end
