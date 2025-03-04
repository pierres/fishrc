if status is-interactive
    function _fishrc_history_merge --on-event fish_postexec
        history merge &
    end
end
