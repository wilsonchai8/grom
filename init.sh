#!/bin/bash
set -o errexit

read -p "please input the local ip address: " LOCAL_IP
read -p "please input the database ip address: " DB_ADDR
read -p "please input the database port: " DB_PORT
read -p "please input the database username: " DB_USER
read -p "please input the database password: " DB_PASS

get_content()
{
    local DB_NAME=$1
    CONFIG="[tornado] \ndebug = false\n\n[log]\nlog_dir = /var/log\n\n[mysql]\nhost = $DB_ADDR\nport = $DB_PORT\nuser = $DB_USER\npassword = $DB_PASS\ndb = $DB_NAME"
}

init_database()
{
    mysql -h$DB_ADDR -P$DB_PORT -u$DB_USER -p$DB_PASS -e "source db_init.sql" 
}

echo "
local_ip: $LOCAL_IP
database_host: $DB_ADDR
database_port: $DB_PORT
database_username: $DB_USER
database_password: $DB_PASS
"
read -p "please confirm (yes/no):  " COMFIRM_RESULT

if [ $COMFIRM_RESULT = 'yes' ];then
    get_content grom_admin && echo "$CONFIG" > grom_admin_app.conf
    get_content grom_config && echo "$CONFIG" > grom_config_app.conf
    init_database
    echo "init success..."
else
    echo "init failed, please retry..."
fi



