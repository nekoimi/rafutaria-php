# rafutaria-php

![](rafutaria.png)

A PHP FPM and Nginx running environment.

### Environment variable

|name|desc|
|:---|:---|
|NGX_WORKER_PROCESSES|配置nginx进程数，默认为1，可选值：auto或数字|
|APPLICATION_ENV|应用运行环境：生产环境 - production|
|CRONTAB_ENABLE|是否启用crontab定时任务，false - 开启 / true - 关闭 |
|COMPOSER_INSTALL|当项目目录下面存在composer.lock文件时自动执行composer install， false - 关闭 / true - 开启|
|COMPOSER_UPDATE|当项目目录下面存在composer.lock文件时自动执行composer update， false - 关闭 / true - 开启|
|PHP_XDEBUG|是否开启php xdebug扩展， on - 开启 / off - 关闭|
|PHP_PM_MODE|php-fpm进程管理模式，默认是dynamic，dynamic - 动态 / static - 静态|
|PHP_PM_MAX_CHILDREN|静态方式下开启的php-fpm进程数量|
|PHP_PM_START_SERVERS|动态方式下的起始php-fpm进程数量|
|PHP_PM_MIN_SPARE_SERVERS|动态方式下的最小php-fpm进程数量|
|PHP_PM_MAX_SPARE_SERVERS|动态方式下的最大php-fpm进程数量|
|PHP_PM_MAX_REQUESTS|请求数累积到一定数量后，自动重启该进程|

### Used

- php 7.1.33:

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/nekoimi/rafutaria-php/7.1.33-fpm-alpine3.10)](https://hub.docker.com/r/nekoimi/rafutaria-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

```shell
docker pull nekoimi/rafutaria-php:7.1.33-fpm-alpine3.10
```


- php 7.2.34:

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/nekoimi/rafutaria-php/7.2.34-fpm-alpine3.12)](https://hub.docker.com/r/nekoimi/rafutaria-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

```shell
docker pull nekoimi/rafutaria-php:7.2.34-fpm-alpine3.12
```


- php 7.4.30:

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/nekoimi/rafutaria-php/7.4.30-fpm-alpine3.16)](https://hub.docker.com/r/nekoimi/rafutaria-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

```shell
docker pull nekoimi/rafutaria-php:7.4.30-fpm-alpine3.16
```


- php 8.1.7:

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/nekoimi/rafutaria-php/8.1.7-fpm-alpine3.16)](https://hub.docker.com/r/nekoimi/rafutaria-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

```shell
docker pull nekoimi/rafutaria-php:8.1.7-fpm-alpine3.16
```
