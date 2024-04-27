function tar-diff --description='Create a patch file containing the differences between the content of two tar archives'
    # check if required tools are installed
    if not command -q bsdtar
        echo 'bsdtar command not found'
        fish_command_not_found bsdtar
        return 1
    end

    if not command -q diff
        echo 'diff command not found'
        fish_command_not_found diff
        return 1
    end

    # check if arguments are valid
    if test (count $argv) -ne 2
        set -l command (status current-command)
        echo "usage: $command <tar1> <tar2>"
        return 1
    end

    for tar in $argv
        if not test -f "$tar"
            echo "file '$tar' not found"
            return 1
        end
    end

    set -l a $argv[1]
    set -l b $argv[2]

    set -l aname (path basename $a)
    set -l bname (path basename $b)

    if test "$aname" = "$bname"
        echo 'filenames cannot be identical'
        return 1
    end

    # Extract tar files into temporary directories
    set -l tmpdir (mktemp -d -t tar-diff.XXXXXXXXXX)
    trap "rm -rf '$tmpdir'" EXIT INT
    mkdir "$tmpdir/$aname" "$tmpdir/$bname"

    bsdtar xf "$a" --strip-components=1 -C "$tmpdir/$aname" &
    bsdtar xf "$b" --strip-components=1 -C "$tmpdir/$bname" &
    wait

    # create a patch file
    begin
        pushd "$tmpdir"
        diff -Nura "$aname" "$bname"
        popd
    end >"$aname-$bname.patch"

    rm -rf "$tmpdir"
end
