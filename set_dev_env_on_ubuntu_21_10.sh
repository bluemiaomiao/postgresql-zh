#!/usr/bin/env bash

echo '您的系统信息如下:'
cat /etc/os-release

echo '[1/7] 安装基本开发环境...'
sudo apt update && sudo apt upgrade
sudo apt install git build-ess* gdb make cmake clang

echo '[2/7] 安装一些常用的开发工具...'
sudo apt install tree unzip zip lrzsz bash-comp* vim diffutils uuid net-tools wget curl

echo '[3/7] 安装编译 PostgreSQL 14.1 所需的开发库支持...'
sudo apt install libreadline8 libreadline-dev readline-common readline-doc zlib1g zlib1g-dev lz4 liblz4-tool liblz4-dev icu-devtools icu-doc libicu-dev libicu67 gettext gettext-base gettext-doc gettext-el libgettextpo-dev libgettextpo0 flex flex-doc flexbackup flexbar flexc++ flexloader bison bison-doc libbison-dev krb5-* libkrb5-* libxslt1.1 libxslt1-dev libxml2-* openssl libssl-dev libssl-doc libossp-uuid-dev libossp-uuid16 python python3 python2-dev python3-dev python-pip tcl tcl-dev tcl-doc tcl-expect tcl-expect-dev perl libperl-dev libpam0g libpam0g-dev ldap-* libldap-2.5-0 libldap-common libldap2-dev libselinux1 libselinux1-dev libsystemd0 libsystemd-dev

echo '[4/7] 下载 PostgreSQL 源代码到 /root/postgresql ...'
cd /root
git clone https://git.postgresql.org/git/postgresql.git
cd postgresql
git checkout REL_14_1

echo '[5/7] 编译源代码...'
./configure --prefix=/usr/local/pgsql \
--datadir=/usr/local/pgsql/data \
--enable-debug \
--enable-cassert \
--with-icu \
--with-tcl \
--with-perl \
--with-python \
--with-gssapi \
--with-krb-srvnam=postgres \
--with-pam \
--with-ldap \
--with-selinux \
--with-systemd \
--with-uuid=ossp \
--with-libxml \
--with-libxslt \
--with-lz4 \
--with-ssl=openssl
make -j
make install

echo '[6/7] 创建一些 PostgreSQL 所需要的文件和目录...'
adduser postgres
mkdir -p /var/lib/pgsql/data
mkdir -p /var/log/pgsql
chown -R postgres:postgres /var/lib/pgsql/
chown -R postgres:postgres /var/log/pgsql/
su - postgres
echo 'export PATH=$PATH:/usr/local/pgsql/bin' >> ~/.bashrc
source ~/.bashrc

echo '[7/7] 初始化 PostgreSQL 并尝试启动服务...'
initdb -D /var/lib/pgsql/data
pg_ctl -D /var/lib/pgsql/data/ -l /var/log/pgsql/server.log start
pg_ctl -D /var/lib/pgsql/data/ -l /var/log/pgsql/server.log stop

echo '恭喜, 开发环境准备完成!'
echo '安装目录: /usr/local/pgsql'
echo '数据目录: /var/lib/pgsql/data'
echo '日志目录: /var/log/pgsql'
echo '启动命令: pg_ctl -D /var/lib/pgsql/data/ -l /var/log/pgsql/server.log start'
echo '关闭命令: pg_ctl -D /var/lib/pgsql/data/ -l /var/log/pgsql/server.log stop'

