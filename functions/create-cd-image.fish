function create-cd-image --description 'Create cue/bin image file of a CD-ROM'
    if not command -q cdrdao
        echo 'cdrdao command not found' >&2
        fish_command_not_found cdrdao
        return 1
    end

    if not command -q toc2cue
        echo 'toc2cue command not found' >&2
        fish_command_not_found toc2cue
        return 1
    end

    if test -z "$argv[1]"
        echo "Error: No image name given" >&2
        return 1
    end

    set -l name $argv[1]

    # see https://www.dosbox.com/wiki/Cuesheet
    cdrdao read-cd --datafile "$name.bin" --driver generic-mmc:0x20000 --device /dev/cdrom --read-raw "$name.toc"
    toc2cue "$name.toc" "$name.cue"
    rm "$name.toc"
end
