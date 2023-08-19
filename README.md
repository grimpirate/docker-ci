# CodeIgniter on Alpine Linux Dockerfile
## Config
https://docs.docker.com/engine/security/rootless/
https://stackoverflow.com/questions/413807/is-there-a-way-for-non-root-processes-to-bind-to-privileged-ports-on-linux

```
sysctl net.ipv4.ip_unprivileged_port_start=80
```
## Build
```
docker build -t codeigniter .
```
## Run
```
docker run -dp 80:80 -i codeigniter
```
## Docker Launch
```
systemctl --user start docker-desktop
```
## Prune
```
docker system prune -a
docker container prune
docker volume prune
docker builder prune
docker image prune
```