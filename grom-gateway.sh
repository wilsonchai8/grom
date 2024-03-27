#!/bin/bash

domain=127.0.0.1

image=registry.cn-beijing.aliyuncs.com/wilsonchai/grom-gateway:$1
name=grom-gateway
docker pull $image
docker rm -f $name
docker run -d --restart=always  --name=$name\
    --add-host bd.grom-devops.com:$domain \
    -p 9999:80 \
    $image 
