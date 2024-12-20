# Borra uno por uno los objetos de Docker que no están en uso (quitar lo que no queremos borrar)
function cleanDocker(){
  docker rm $(docker ps -a -q) 2>/dev/null
  docker rmi $(docker images -q) 2>/dev/null
  docker volume rm $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q) 2>/dev/null
}

# Borra todo completamente
function cleanDockerAll(){
  docker stop $(docker ps -q) 2>/dev/null
  docker system prune --all --volumes -f
}

