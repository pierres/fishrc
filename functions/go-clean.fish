function go-clean --description 'Clean all Go caches'
    go clean -cache -modcache -testcache -fuzzcache
end
