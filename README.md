```
vagrant up
```
手動安裝nginx
```
cd /data


cp nginx-1.20.1.tar.gz  /usr/local/src
cd  /usr/local/src
tar zxvf nginx-1.20.1.tar.gz
cd nginx-1.20.1
apt-get update
apt install gcc
apt-get install libpcre3 libpcre3-dev
apt-get install zlib1g-dev
apt install pcre-devel
./configure --prefix=/usr/local/nginx
apt-get install build-essential
make && make install
```

啟動
```
cd /usr/local/nginx
```
看到如下四個目錄

conf 配置文件
html 網頁文件
logs 日誌文件
sbin 進程文件

```
./sbin/nginx
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] still could not bind()
```
不能綁定80端口

```
root@vagrant:/usr/local/nginx# netstat -antp
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      24377/nginx: master
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      562/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1924/sshd: /usr/sbi
tcp        0      0 10.0.2.15:22            10.0.2.2:61465          ESTABLISHED 12847/sshd: vagrant
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
tcp6       0      0 :::22                   :::*                    LISTEN      1924/sshd: /usr/sbi

```