function _fishrc_reset_config --description 'Reset Fish configuration and reconfigure fishrc'
    argparse if-needed -- $argv; or return

    set -l config_revision 1
    if set -q _flag_if_needed; and test "$_fishrc_config_revision" = "$config_revision"
        return 0
    end

    for e in (set -nU)
        if test $e != __fish_initialized
            set -eU $e
        end
    end

    yes | fish_config theme save Tomorrow\ Night\ Bright; or return

    tide configure \
        --auto \
        --style=Rainbow \
        --prompt_colors='True color' \
        --show_time=No \
        --rainbow_prompt_separators=Angled \
        --powerline_prompt_heads=Sharp \
        --powerline_prompt_tails=Flat \
        --powerline_prompt_style='One line' \
        --prompt_spacing=Compact \
        --icons='Few icons'; or return

    set -U fish_greeting

    set tide_right_prompt_items status cmd_duration context jobs
    set tide_pwd_icon_unwritable 🗲
    tide reload; or return

    set -U _fishrc_config_revision $config_revision
end
