function cleanDocker(){
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q) 2>/dev/null
  docker rmi $(docker images -q) 2>/dev/null
  docker volume rm $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q) 2>/dev/null
  docker system prune --all --volumes -f
}
