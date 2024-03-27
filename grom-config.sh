#!/bin/bash

current_dir=`pwd`
image=grom-config:$1
name=grom-config
# docker pull $image
docker rm -f $name
docker run -d --restart=always  --name=$name\
    -v $current_dir/grom_config_app.conf:/opt/grom-config/app.conf \
    -p 10002:10002 \
    $image 
