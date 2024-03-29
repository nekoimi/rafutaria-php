# Rafutaria-php

[![License](https://img.shields.io/badge/license-Apache-blue)](https://github.com/nekoimi/rafutaria-php)
[![php7.1](https://img.shields.io/badge/php-7.1-blue)](https://github.com/nekoimi/rafutaria-php)
[![php7.2](https://img.shields.io/badge/php-7.2-blue)](https://github.com/nekoimi/rafutaria-php)
[![php7.4](https://img.shields.io/badge/php-7.4-blue)](https://github.com/nekoimi/rafutaria-php)
[![php8](https://img.shields.io/badge/php-8-blue)](https://github.com/nekoimi/rafutaria-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/nekoimi/rafutaria-php)](https://hub.docker.com/r/nekoimi/rafutaria-php)

![](rafutaria.png)

一个PHP运行环境，集成yaf、redis、xdebug、swoole等常用扩展。

### Run mode

|fpm|cli|
|:-----:|:-----:|
|php + nginx|php|

### Environment variable

|name| desc                                                                  |fpm|cli|
|:---|:----------------------------------------------------------------------|:---:|:---:|
|APPLICATION_ENV| 应用运行环境：生产环境 - production(composer install --no-dev)                   |√|√|
|NGX_WORKER_PROC| 配置nginx进程数，默认为1，可选值：auto或number                                       |√|-|
|COMPOSER_INSTALL| 当项目目录下面存在composer.lock文件时自动执行composer install， false - 关闭 / true - 开启 |√|√|
|COMPOSER_UPDATE| 当项目目录下面存在composer.lock文件时自动执行composer update， false - 关闭 / true - 开启  |√|√|
|CRONTAB_ENABLE| 是否启用crontab定时任务，false - 开启 / true - 关闭                                |√|√|
|XDEBUG_ENABLE| 是否开启php xdebug扩展， false - 关闭 / true - 开启                              |√|√|
|MEMORY_LIMIT| 内存限制                                                                  |√|-|
|UPLOAD_MAX_SIZE| 上传文件大小限制                                                              |√|-|
|PHP_PM_MODE| php-fpm进程管理模式，默认是dynamic，dynamic - 动态 / static - 静态                   |√|-|
|PHP_PM_MAX_CHILDREN| 静态方式下开启的php-fpm进程数量                                                   |√|-|
|PHP_PM_START_SERVERS| 动态方式下的起始php-fpm进程数量                                                   |√|-|
|PHP_PM_MIN_SPARE_SERVERS| 动态方式下的最小php-fpm进程数量                                                   |√|-|
|PHP_PM_MAX_SPARE_SERVERS| 动态方式下的最大php-fpm进程数量                                                   |√|-|
|PHP_PM_MAX_REQUESTS| 请求数累积到一定数量后，自动重启该进程                                                   |√|-|

### Used

```shell
docker pull nekoimi/rafutaria-php:{version}-{mode}-alpine
```

|version|image of fpm|image of cli|
|:-----:|:-----:|:-----:|
|7.1|**nekoimi/rafutaria-php:7.1-fpm-alpine**|**nekoimi/rafutaria-php:7.1-cli-alpine**|
|7.2|**nekoimi/rafutaria-php:7.2-fpm-alpine**|**nekoimi/rafutaria-php:7.2-cli-alpine**|
|7.4|**nekoimi/rafutaria-php:7.4-fpm-alpine**|**nekoimi/rafutaria-php:7.4-cli-alpine**|
|8|**nekoimi/rafutaria-php:8-fpm-alpine**|**nekoimi/rafutaria-php:8-cli-alpine**|
