# install global configuration to specified root directory
install target:
	install -D -m644 conf.d/* -t "{{target}}/etc/fish/conf.d"
	install -D -m644 functions/* -t "{{target}}/etc/fish/functions"
