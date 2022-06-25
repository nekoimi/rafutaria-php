# Rafutaria-php

[![License](https://img.shields.io/badge/license-Apache-blue)](https://github.com/nekoimi/rafutaria-php)
![php7.1](https://img.shields.io/badge/php-7.1-blue)
![php7.2](https://img.shields.io/badge/php-7.2-blue)
![php7.4](https://img.shields.io/badge/php-7.4-blue)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

![](rafutaria.png)

一个PHP运行环境，集成常用扩展。

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

- **php 7.1**


```shell
docker pull nekoimi/rafutaria-php:7.1-fpm-alpine
```


#### cli

- **php 7.1**

```shell
docker pull nekoimi/rafutaria-php:7.1-cli-alpine
```
