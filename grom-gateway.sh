#!/bin/bash

domain=10.22.11.122

image=grom-gateway:$1
name=grom-gateway
# docker pull $image
docker rm -f $name
docker run -d --restart=always  --name=$name\
    --add-host bd.grom-devops.com:$domain \
    -p 9999:80 \
    $image 
