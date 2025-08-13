function _fishrc_check_command --description 'Check if a command exists and print an error if it does not'
    if not command -q $argv[1]
        echo "'$argv[1]' command not found" >&2
        fish_command_not_found $argv[1]
        return 1
    end
    return 0
end
