Deploy script to docker hub (after a version update),
for @hayd to run after a deno version update:

```sh
docker build -f alpine.dockerfile -t alpine .
docker build -f debian.dockerfile -t debian .
docker build -f ubuntu.dockerfile -t ubuntu .

# Update version tags here:
docker tag alpine hayd/deno:alpine-0.2.5
docker tag debian hayd/deno:debian-0.2.5
docker tag ubuntu hayd/deno:ubuntu-0.2.5

docker push hayd/deno
```

Note: It would be good to make these less ad hoc.
e.g. from Docker Hub CI.
https://docs.docker.com/docker-hub/builds/

