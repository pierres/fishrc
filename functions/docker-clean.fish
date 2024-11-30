function docker-clean --description 'Remove all Docker containers, networks and volumes'
    set -l containers (docker ps -q)
    if test -n "$containers"
        docker rm -f $containers
    end
    docker container prune -f
    docker network prune -f
    docker volume prune -af
end
