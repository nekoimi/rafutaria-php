# rafutaria-php

A PHP FPM and Nginx running environment.

### 环境变量

|名称|说明|
|:---:|:---:|
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
