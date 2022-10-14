# CodeIgniter on Alpine Linux Dockerfile
## Build
docker build -t codeigniter .
## Run
docker run -p 80:80 -it codeigniter
## Prune
docker system prune -a
docker container prune
docker volume prune
