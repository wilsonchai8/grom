#devops利器 -- 配置文件管理平台

> ###1）项目介绍

1、在之前的项目中，300+的微服务，500+的配置文件管理起来非常头痛，尝试过各种各样的开源工具，都达不到我想要的结果，于是自己动手写了该项目   
2、支持各种文本类型的配置文件，格式不限，xml、yaml、json皆可  
3、详细的描述了配置文件的生命周期，包括修改、发布、回滚等  
4、在配置文件中，有些重复配置可以抽离出来成为公共配置，一次定义多次使用，比如数据库地址、用户、密码等  


<br>

> ###2）版本说明

| 组件      | 版本                       |
| ------- |------------------------ |
| docker    | 20.10.25 |
| mysql     | mysql8.0+                   |

mysql需要使用8.0+版本，因为项目中mysql使用了timestamp作为时间字段，在8.0以上explicit_defaults_for_timestamp参数默认为on，可以为空；而在其他版本该参数值为off。所以想要在mysql8以下版本使用的话，必须要确保该参数的值为on。

```
mysql> select version();+-----------+| version() |+-----------+| 8.0.33    |+-----------+1 row in set (0.00 sec)mysql> show variables like "%explicit_defaults_for_timestamp%";+---------------------------------+-------+| Variable_name                   | Value |+---------------------------------+-------+| explicit_defaults_for_timestamp | ON    |+---------------------------------+-------+1 row in set (0.00 sec)
```

<br>

> ###3）快速部署

| 组件      | 作用                       |
| ------- | ------------------------ |
| grom-gateway    | 前端静态文件以及api转发网关 |
| grom-admin    | 用户、角色管理以及权限校验  |
| grom-config    | 配置文件管理  |

本项目由三个模块组成，部署的话只需要启动一件部署脚本即可：

a）先下载仓库

```
git clone https://github.com/wilsonchai8/grom.git
```
b）执行一键部署脚本并输入相关信息

```
cd grom
sh init.sh
```

```
▶ sh init.sh
please input the local ip address: 10.22.11.122  #本机机器的ip
please input the database ip address: 10.22.11.122  #数据库所在的ip
please input the database port: 3306  #数据库的端口
please input the database username: root  #数据库的用户
please input the database password: 123456  #数据库的密码

local_ip: 10.22.11.122
database_host: 10.22.11.122
database_port: 3306
database_username: root
database_password: 123456

please confirm (yes/no):  yes
...
```
c）等待片刻之后，出现以下3个容器之后，部署成功

```
▶ docker ps | grep grom
2bda25e5fb4e   registry.cn-beijing.aliyuncs.com/wilsonchai/grom-gateway:latest   "/usr/bin/openresty …"   58 seconds ago       Up 57 seconds       0.0.0.0:9999->80/tcp, :::9999->80/tcp                  grom-gateway
d56b1ed814b8   registry.cn-beijing.aliyuncs.com/wilsonchai/grom-config:latest    "/bin/sh -c 'python3…"   59 seconds ago       Up 58 seconds       0.0.0.0:10002->10002/tcp, :::10002->10002/tcp          grom-config
f303dc093f48   registry.cn-beijing.aliyuncs.com/wilsonchai/grom-admin:latest     "/bin/sh -c 'python3…"   About a minute ago   Up About a minute   0.0.0.0:10001->10001/tcp, :::10001->10001/tcp          grom-admin
```

d）打开页面，通过默认用户登录（该用户登录之后请理解修改密码）

super/12#$qwER

![1](https://tvax2.sinaimg.cn/large/006H5c23ly1homwyyejryj32iq1kyn5x.jpg)

e）部署完成

> ###4）功能介绍


1、控制台

登录之后记得修改密码

![2](https://tvax1.sinaimg.cn//006H5c23ly1homx0gf58bj32iq1kydw7.jpg)


2、用户管理

首先要添加角色才能创建用户，用户与角色是多对一的关系，用户必须要绑定一个角色

系统内置了2个角色，一个管理员角色，一个普通角色

![3](https://tvax2.sinaimg.cn//006H5c23ly1homx1b9guyj32iq1kyk6n.jpg)

创建角色最重要的是绑定权限


| 权限      | 作用                       |
| ------- |------------------------ |
| 菜单权限    | 左侧菜单栏是否可见 |
| 组件权限    | 有一些按钮是否可见，如用户删除、配置发布等                   |
| 请求权限     | 调用后端api是否被允许，一般组件权限与请求全选是联动的                   |

其中组件全选勾选的时候，会联动提示是否请求权限是否一并勾选

![4](https://tvax3.sinaimg.cn//006H5c23ly1homx23s6tej32iq1kygzy.jpg)

3、配置管理，首先看下整个配置文件发布的流程

![5](https://tvax3.sinaimg.cn//006H5c23ly1homx2bowtzj30pv0tr76n.jpg)

首先说明一下两个重要的流程

1）通知  
&emsp;&emsp;1.1）如果配置通知地址，配置文件“发布”之后，会将本次发布的详细内容推送到相关的通知接口  
&emsp;&emsp;1.2）通知接口的设计思路：本项目最主要的作用是管理配置文件，而真正去修改配置文件的动作，需要第三方接口去处理，比如nacos、k8s configmap等  
2）回调  
&emsp;&emsp;2.1）如果配置回调接口，并且需要回调，配置文件“发布”之后，会进入“发布中”状态，等待三方接口通知本次配置文件的发布是否成功  
&emsp;&emsp;2.2）设计思路：如果配置了回调接口，配置文件“发布”是否成功，依赖于三方接口来通知  
3）通知与回调的关系  
&emsp;&emsp;3.1）通知与回调互相配合，但是他们俩并没有逻辑依赖关系
&emsp;&emsp;3.2）既有通知，也有回调： 配置文件“发布”后，通知三方接口，然后配置文件最终的状态，等待三方接口通知最终状态
&emsp;&emsp;3.3）只有通知，没有回调： 配置文件“发布”后，通知三方接口，然后配置文件立即进入最终状态：如果调用三方接口成功，则“发布成功”，否则“发布失败”  
&emsp;&emsp;3.4）没有通知，只有回调： 配置文件“发布”后，进入“发布中”状态，等待三方接口回调通知最终状态  
&emsp;&emsp;3.5）没有通知，没有回调： 配置文件“发布”后，立即进入“发布成功”状态


3.1 首先需要创建回调token

![6](https://tvax3.sinaimg.cn//006H5c23ly1homx2it3pgj32iq1kyncz.jpg)

3.2 首先需要创建环境，环境由名称+前缀组成，比如阿里预发布：名称（ali）+前缀（pre）

| 字段      | 作用                       |
| ------- |------------------------ |
| 名称    | 表达环境的第一维说明 |
| 前缀    | 表达环境的第二维说明 |
| 备注    | 表达该环境的用途 |
| 通知地址    | 发布普通配置之后会往该地址通知本次发布的配置详细内容 |
| 是否回调    | 如果打开，则表示需要进行地址回调通知本次配置文件发布的结果 |
| 回调token    | 回调需要带上的token作为验证 |

![7](https://tvax1.sinaimg.cn//006H5c23ly1homx2ummxfj32iq1ky7l1.jpg)

3.3 创建普通配置

| 字段      | 作用                       |
| ------- |------------------------ |
| 名称    | 配置文件名字： web.xml、server.conf等 |
| 所属服务    | 服务的名称 |
| 环境    | 服务部署的环境，环境名与前缀会自动展现 |
| 内容    | 配置文件的内容 |

![8](https://tvax2.sinaimg.cn//006H5c23ly1homx32ra8hj32iq1kygzd.jpg)

3.4 发布/回滚 

3.5 操作记录与版本查看

4、公共配置管理

设计思路     

&emsp;&emsp;a）需要多个配置文件复用的配置项，比如数据库地址、端口等，单独抽离出来方便之后的增删改查  
&emsp;&emsp;b）敏感的配置项，比如数据库密码、token等，单独抽离出来，然后配置查看权限，可以避免核心配置泄露 
&emsp;&emsp;c）公共配置本质就是一个key-value数据库  
&emsp;&emsp;d）普通配置想要引用公共配置，通过<<<key>>>，并且必须在同一个环境下  


4.1 新建公共配置

| 字段      | 作用                       |
| ------- |------------------------ |
| 环境    | 服务部署的环境，环境名与前缀会自动展现 |
| key    | 公共配置的key |
| value    | 公共配置的value |

![9](https://tvax1.sinaimg.cn//006H5c23ly1homx3cmitij32iq1kydw1.jpg)
 
4.2 公共配置的操作

● 公共配置的操作没有普通配置这么复杂，新建、修改、发布、回滚，并且没有通知与回调的操作  
● 需要注意的是，公共配置必须要发布之后才能生效

![10](https://tvax3.sinaimg.cn//006H5c23ly1homx3l3ajvj32iq1kyaq1.jpg)
 
4.3 普通配置引用公共配置

注： 公共配置一定要发布之后才能被普通配置引用

![13](https://tvax2.sinaimg.cn//006H5c23ly1homx46q5ynj32iq1kyap5.jpg)

三个尖括号包裹被引用的key，<<<key>>>，可以点击渲染按钮来确认公共配置是否已经引用成功

![14](https://tvax4.sinaimg.cn//006H5c23ly1homx4dwz56j32iq1kyndo.jpg)

4.4 查看关联配置 

● 修改了公共配置之后，需要通知普通配置重新发布，使公共配置生效  
● 比如修改了数据库地址，需要所有引用了该公共配置的普通配置文件重新发布  

![11](https://tvax3.sinaimg.cn//006H5c23ly1homx3ro2lcj32iq1kywvx.jpg)

<br>

> ###5）联系我

有问题可以去github提issue，或者直接联系我

![12](https://tvax2.sinaimg.cn//006H5c23ly1homx40gluqj30qe100tau.jpg)

***

至此，本文结束  
在下才疏学浅，有撒汤漏水的，请各位不吝赐教...
