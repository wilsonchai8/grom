#!/bin/bash

current_dir=`pwd`
image=registry.cn-beijing.aliyuncs.com/wilsonchai/grom-admin:$1
name=grom-admin
docker pull $image
docker rm -f $name
docker run -d --restart=always  --name=$name\
    -v $current_dir/grom_admin_app.conf:/opt/grom-admin/app.conf \
    -p 10001:10001 \
    $image 
