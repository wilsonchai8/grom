CREATE DATABASE IF NOT EXISTS grom_admin DEFAULT CHARSET UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_admin`.`user`(
   `id`                               INT AUTO_INCREMENT,
   `username`                         VARCHAR(64) NOT NULL,
   `password`                         VARCHAR(64) NOT NULL,
   `role_id`                          INT,
   `super`                            INT NOT NULL DEFAULT 0,
   `nickname`                         VARCHAR(64),
   `email`                            VARCHAR(64),
   `contact`                          VARCHAR(256),
   `status`                           BOOLEAN NOT NULL,
   `last_login_time`                  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   `create_time`                      DATETIME DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (`id`),
   UNIQUE KEY(`username`),
   INDEX (create_time)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_admin`.`role`(
   `id`                               INT AUTO_INCREMENT,
   `rolename`                         VARCHAR(64) NOT NULL,
   `routes`                           VARCHAR(1000) DEFAULT '',
   `components`                       VARCHAR(1000) DEFAULT '',
   `requests`                         VARCHAR(1000) DEFAULT '',
   `comment`                          VARCHAR(1000) DEFAULT '',
   PRIMARY KEY (`id`),
   UNIQUE KEY(`rolename`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_admin`.`token`(
   `id`                               INT AUTO_INCREMENT,
   `tokenname`                        VARCHAR(64) NOT NULL,
   `tokenkey`                         VARCHAR(64) NOT NULL,
   `payload`                          VARCHAR(256) DEFAULT '',
   PRIMARY KEY (`id`),
   UNIQUE KEY(`tokenname`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

INSERT INTO grom_admin.user(role_id, username, password, nickname, status, super) values(0, 'super', '9c46b88a4191a7907fad086fc57c630f', '超级管理员', 1, 1);
INSERT INTO grom_admin.role(rolename, routes, components, requests, `comment`) values('normal', '', '', '', '普通角色');
INSERT INTO grom_admin.role(rolename, routes, components, requests, `comment`) values('admin', '/config/public,/config/env,/user/user-list,/user/role-list,/user/token-list,/user/role-edit', 'general_add_but,general_enable_disable_but,general_publish_but,general_rollback_but,general_render_but,public_add_but,public_delete_but,public_publish_but,public_rollback_but,public_related_general_publish_but,env_add_but,env_edit_but,env_delete_but,user_add_but,user_edit_but,user_enable_disable_but,role_add_but,role_edit_but,role_delete_but,token_add_but,token_delete_but', '/config/general:post,/config/general:delete,/config/general/publish:post,/config/general/rollback:post,/config/general/render:post,/config/public:post,/config/public:delete,/config/public/publish:post,/config/public/rollback:post,/config/public/related_general:post,/config/env:post,/config/env:put,/config/env:delete,/admin/user/users:post,/admin/user/users:put,/admin/user/users:delete,/admin/user/roles:post,/admin/user/roles:put,/admin/user/roles:delete,/admin/user/token:post,/admin/user/token:delete', '管理员');

CREATE DATABASE IF NOT EXISTS grom_config DEFAULT CHARSET UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`general`(
    `id`                               INT AUTO_INCREMENT,
    `name`                             VARCHAR(100) NOT NULL,
    `env_id`                           INT NOT NULL,
    `belongto`                         VARCHAR(256),
    `is_delete`                        BOOL DEFAULT FALSE,
    `meta`                             JSON,
    `create_time`                      TIMESTAMP(6),
    `creator`                          VARCHAR(64),
    PRIMARY KEY (`id`),
    CONSTRAINT col_unique UNIQUE (`name`, `env_id`, `belongto`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`general_version`(
    `id`                               INT AUTO_INCREMENT,
    `general_id`                       INT NOT NULL,
    `name`                             VARCHAR(100) NOT NULL,
    `content`                          Text,
    `status`                           VARCHAR(255) NOT NULL,
    `is_publish`                       BOOL DEFAULT FALSE,
    `publish_time`                     TIMESTAMP(6) DEFAULT NULL,
    `publisher`                        VARCHAR(50) DEFAULT NULL,
    `update_time`                      TIMESTAMP(6) NOT NULL,
    `modifier`                         VARCHAR(50) NOT NULL,
    INDEX (`general_id`),
    INDEX (`update_time`),
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`general_version_log`(
    `id`                               INT AUTO_INCREMENT,
    `general_id`                       INT NOT NULL,
    `general_version_id`               INT NOT NULL,
    `name`                             VARCHAR(100) NOT NULL,
    `info`                             Text,
    `status`                           VARCHAR(255) NOT NULL,
    `update_time`                      TIMESTAMP(6) NOT NULL,
    `modifier`                         VARCHAR(50) NOT NULL,
    INDEX (`general_id`),
    INDEX (`general_version_id`),
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`env`(
    `id`                               INT AUTO_INCREMENT,
    `name`                             VARCHAR(100) NOT NULL,
    `prefix`                           VARCHAR(256),
    `comment`                          VARCHAR(256),
    `notification`                     VARCHAR(256),
    `notification_token`               VARCHAR(256),
    `is_callback`                      BOOL DEFAULT FALSE,
    `callback_token`                   VARCHAR(256),
    `update_time`                      TIMESTAMP(6),
    `modifier`                         VARCHAR(64),
    PRIMARY KEY (`id`),
    CONSTRAINT col_unique UNIQUE (`name`, `prefix`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`public_item`(
    `id`                               INT AUTO_INCREMENT,
    `env_id`                           INT NOT NULL,
    `k`                                VARCHAR(255) NOT NULL,
    `meta`                             JSON,
    `create_time`                      TIMESTAMP(6) NOT NULL,
    `creator`                          VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT col_unique UNIQUE (`env_id`, `k`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`public_item_version`(
    `id`                               INT AUTO_INCREMENT,
    `public_item_id`                   INT NOT NULL,
    `name`                             VARCHAR(100) NOT NULL,
    `v`                                VARCHAR(255) NOT NULL,
    `status`                           VARCHAR(255) NOT NULL,
    `publish_time`                     TIMESTAMP(6) DEFAULT NULL,
    `publisher`                        VARCHAR(50) DEFAULT NULL,
    `update_time`                      TIMESTAMP(6) NOT NULL,
    `modifier`                         VARCHAR(50) NOT NULL,
    INDEX (`name`),
    INDEX (`public_item_id`),
    INDEX (`update_time`),
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE IF NOT EXISTS `grom_config`.`public_item_version_record`(
    `id`                               INT AUTO_INCREMENT,
    `public_item_version_id`           INT NOT NULL,
    `general_version_id`               INT NOT NULL,
    `msg`                              VARCHAR(255),
    `update_time`                      TIMESTAMP(6) NOT NULL,
    `modifier`                         VARCHAR(50) NOT NULL,
    INDEX (`public_item_version_id`, `general_version_id`),
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
