# check syntax and format of fish and just files
check:
    find . -type f -name '*.fish' -print -exec fish --no-execute {} +
    find . -type f -name '*.fish' -print -exec fish_indent -c {} +
    just --unstable --fmt --check

# format fish and just files
fmt:
    find . -type f -name '*.fish' -print -exec fish_indent -w {} +
    just --unstable --fmt

# install global configuration to specified root directory
install target:
    install -D -m644 conf.d/* -t "{{ target }}/etc/fish/conf.d"
    install -D -m644 functions/* -t "{{ target }}/etc/fish/functions"
